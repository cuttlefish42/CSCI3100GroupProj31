class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @login_url = session_url
    mail(to: @user.email_address, subject: "Welcome to Group 31 platform!")
  end

  def password_reset(user)
    @user = user
    @reset_url = edit_password_url(@user.password_reset_token)
    mail(to: @user.email_address, subject: "Reset Your Password Now!")
  end

  def new_offer_notify(user, item, offer)
    @user = user
    @item = item
    @offer = offer
    @item_url = item_url(item)
    @offer_url = item_offer_url(item, offer)
    mail(to: @user.email_address, subject: "New offer for #{item.title}")
  end
end
