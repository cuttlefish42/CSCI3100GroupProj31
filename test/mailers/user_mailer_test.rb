require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers
  
  setup do
    # set the default url
    Rails.application.routes.default_url_options[:host] = "localhost"
    Rails.application.routes.default_url_options[:port] = 3000
    
    # create user 
    @user = User.find_by(email_address: "test@example.com") || User.create!(
      email_address: "test@example.com",
      username: "tester",
      password: "password123",
      password_confirmation: "password123"
    )
    
    # create item
    @category = Category.first || Category.create!(name: "Electronics")
    @item = Item.find_by(title: "Test Item") || Item.create!(
      title: "Test Item",
      price: 100,
      condition: "good",
      status: "available",
      category: @category,
      seller: @user,
      meetup_note: "Test location"
    )
    
    
    # create buyer
    @buyer = User.find_by(email_address: "buyer@example.com") || User.create!(
      email_address: "buyer@example.com",
      username: "buyer",
      password: "password123",
      password_confirmation: "password123"
    )
    
    # create offer
    @offer = Offer.find_by(item: @item, buyer: @buyer) || Offer.create!(
      item: @item,
      buyer: @buyer,
      price_offered: 50,
      status: "pending"
    )
  end

  # get the body of the email
  def email_body(email)
    if email.html_part
      email.html_part.body.to_s
    else
      email.body.to_s
    end
  end

  test "welcome_email" do
    email = UserMailer.welcome_email(@user)
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@user.email_address], email.to
    assert_equal "Welcome to Group 31 platform!", email.subject
    
    body = email_body(email)

    assert body.include?(@user.username), "Body should contain username"

    assert body.include?("Welcome"), "Body should contain Welcome"
  end

  test "password_reset_email" do
    email = UserMailer.password_reset(@user)
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@user.email_address], email.to
    assert_equal "Reset Your Password Now!", email.subject
    body = email_body(email)
    assert body.include?("Reset Password"), "Body should contain reset password link"
    assert body.include?("/passwords/"), "Body should contain password reset path"
  end

  test "new_item_notify_email" do
    email = UserMailer.new_item_notify(@user, @item, @offer)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [@user.email_address], email.to
    assert_equal "New offer for #{@item.title}", email.subject
    body = email_body(email)
    assert body.include?("New Offer Received"), "Body should contain New Offer Received"
    assert body.include?(@item.title), "Body should contain item title"
    assert body.include?("50.00"), "Body should contain offer price"
  end

  test "email_contains_correct_links" do
    email = UserMailer.new_item_notify(@user, @item, @offer)
    
    body = email_body(email)
    assert body.include?("/items/#{@item.id}"), "Body should contain item path"
    assert body.include?("/offers/#{@offer.id}"), "Body should contain offer path"
  end
end