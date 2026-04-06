# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    user = User.first || User.new(email_address: "test@example.com", username: "tester")
    UserMailer.welcome_email(user)
  end

  def password_reset
    user = User.first || User.new(email_address: "test@example.com", username: "tester")
    UserMailer.password_reset(user)
  end

  def new_offer_notify
    user = User.first || User.new(email_address: "seller@example.com", username: "seller")
    item = Item.first || Item.new(title: "Sample Item")
    offer = Offer.first || Offer.new(price_offered: 100)
    UserMailer.new_offer_notify(user, item, offer)
  end
end
