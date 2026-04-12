test "seller is notified when a new offer is made" do
    given "a buyer is on the item page" do
      as(@buyer) { visit item_path(@item) }
    end

    when_ "the buyer submits an offer" do
      assert_emails 1 do
        make_offer(95)
      end
    end

    then_ "the seller receives a notification email" do
      mail = last_email
      assert_equal [@seller.email_address], mail.to
      assert_match "New offer for #{@item.title}", mail.subject
      assert_match "95", mail.body.encoded
    end
  end