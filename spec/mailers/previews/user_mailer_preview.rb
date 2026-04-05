class UserMailerPreview < ActionMailer::Preview
  # welcome_email
  def welcome_email
    user = User.first || User.new(email: "test@example.com")
    UserMailer.welcome_email(user)
  end

  # reset password
  def password_reset
    user = User.first || User.new(email: "test@example.com")
    user.password_reset_token = "test-token-123"
    UserMailer.password_reset(user)
  end

  # preview new offer 
  def new_offer_notification
    user = User.first || User.new(email: "seller@example.com")
    item = Item.first || Item.new(title: "Sample Item")
    offer = Offer.new(price_offered: 100)
    UserMailer.new_offer_notification(user, item, offer)
  end
end