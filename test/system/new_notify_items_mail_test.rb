require "application_system_test_case"

class NewNotifyItemsMailTest < ApplicationSystemTestCase
  setup do
    @seller = create_sample_user(email_address: "seller@link.cuhk.edu.hk")
    @buyer = create_sample_user(email_address: "buyer@link.cuhk.edu.hk")
    
    create_sample_categories
    create_sample_communities
    
    @item = Item.create!(
      title: "Test Item", 
      price: 100, 
      condition: :good, 
      status: :available, 
      seller: @seller,
      category: Category.first,
      community: Community.first
    )
    
    clear_emails
  end

  test "seller is notified when a new offer is made" do
    given "a buyer is on the item page" do
      system_sign_in(@buyer)
      visit item_path(@item)
    end

    when_ "the buyer submits an offer" do
      click_on "Make Offer"
      fill_in "Price offered", with: 95
      
      assert_emails 1 do
        click_button "Submit Offer"
      end
    end

    then_ "the seller receives a notification email" do
      mail = last_email
      assert_equal [@seller.email_address], mail.to
      assert_match "New offer for #{@item.title}", mail.subject
      assert_match "95", mail.body.encoded
    end
  end
end