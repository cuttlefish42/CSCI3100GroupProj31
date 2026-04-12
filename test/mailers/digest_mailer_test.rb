require "test_helper"

class DigestMailerTest < ActionMailer::TestCase
  test "daily_digest sends to user" do
    user = users(:one)
    mail = DigestMailer.daily_digest(user)

    assert_equal "Your Daily Marketplace Digest", mail.subject
    assert_equal [user.email_address], mail.to
  end

  test "daily_digest includes recent items" do
    user = users(:one)
    item = items(:one)
    item.update_columns(created_at: 1.hour.ago, status: :available)

    mail = DigestMailer.daily_digest(user)
    assert_match item.title, mail.body.encoded
  end
end
