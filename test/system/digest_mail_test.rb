require "application_system_test_case"

class DigestMailTest < ApplicationSystemTestCase
  setup do
    @user = create_sample_user(
      email_address: "digest_user@link.cuhk.edu.hk",
      first_name: "Daily",
      last_name: "Reader"
    )

    create_sample_categories
    create_sample_communities

    @recent_item = Item.create!(
      title: "Fresh Book",
      price: 50,
      condition: :good,
      status: :available,
      seller: @user,
      category: Category.first,
      community: Community.first,
      created_at: 2.hours.ago
    )

    @old_item = Item.create!(
      title: "Old Lamp",
      price: 20,
      condition: :good,
      status: :available,
      seller: @user,
      category: Category.first,
      community: Community.first,
      created_at: 3.days.ago
    )

    clear_emails
  end

  test "daily digest contains only recently created items" do
    given "there are items of different ages in the marketplace" do
      # Items already created in setup
    end

    when_ "the daily digest is generated for the user" do
      DigestMailer.daily_digest(@user).deliver_now
    end

    then_ "the email is addressed to the user and includes only recent items" do
      assert_equal 1, ActionMailer::Base.deliveries.count, "Expected 1 email to be sent"
      
      mail = last_email
      assert_equal [@user.email_address], mail.to
      assert_equal "Your Daily Marketplace Digest", mail.subject
      assert_match @recent_item.title, mail.body.encoded
      refute_match @old_item.title, mail.body.encoded
    end
  end
end
