require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  setup do
    Rails.application.routes.default_url_options[:host] = "localhost"
    Rails.application.routes.default_url_options[:port] = 3000

    @seller = users(:one)
    @buyer = users(:two)
    @item = items(:one)
    @offer = offers(:one)
  end

  # --- welcome_email ---

  test "welcome_email sends to correct recipient" do
    email = UserMailer.welcome_email(@seller)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@seller.email_address], email.to
    assert_equal "Welcome to Group 31 platform!", email.subject
  end

  test "welcome_email body contains username and login link" do
    email = UserMailer.welcome_email(@seller)
    body = email_body(email)

    assert_includes body, @seller.username
    assert_includes body, "Welcome"
    assert_includes body, "/session"
  end

  # --- password_reset ---

  test "password_reset sends to correct recipient" do
    email = UserMailer.password_reset(@seller)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@seller.email_address], email.to
    assert_equal "Reset Your Password Now!", email.subject
  end

  test "password_reset body contains reset link" do
    email = UserMailer.password_reset(@seller)
    body = email_body(email)

    assert_includes body, "Reset Password"
    assert_includes body, "/passwords/"
  end

  # --- new_offer_notify ---

  test "new_offer_notify sends to correct recipient" do
    email = UserMailer.new_offer_notify(@seller, @item, @offer)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@seller.email_address], email.to
    assert_equal "New offer for #{@item.title}", email.subject
  end

  test "new_offer_notify body contains item and offer details" do
    email = UserMailer.new_offer_notify(@seller, @item, @offer)
    body = email_body(email)

    assert_includes body, @item.title
    assert_includes body, "New Offer Received"
    assert_includes body, @offer.price_offered.to_s
  end

  test "new_offer_notify body contains correct links" do
    email = UserMailer.new_offer_notify(@seller, @item, @offer)
    body = email_body(email)

    assert_includes body, "/items/#{@item.id}"
    assert_includes body, "/offers/#{@offer.id}"
  end

  # --- layout HTML structure ---

  test "email layout has proper closing div tags" do
    email = UserMailer.new_offer_notify(@seller, @item, @offer)
    body = email_body(email)

    assert_includes body, "</div>", "Email layout must have proper closing </div> tags"
    # Ensure no unclosed <div> used as closing tag
    refute_match %r{<div>\s*</body>}m, body, "Found <div> where </div> was expected"
  end

  test "email layout contains header and footer" do
    email = UserMailer.new_offer_notify(@seller, @item, @offer)
    body = email_body(email)

    assert_includes body, "Group31"
    assert_includes body, "Group 31"
  end

  test "email is sent from correct address" do
    email = UserMailer.new_offer_notify(@seller, @item, @offer)

    assert_equal ["noreply@group31.com"], email.from
  end

  private

  def email_body(email)
    if email.html_part
      email.html_part.body.to_s
    else
      email.body.to_s
    end
  end
end
