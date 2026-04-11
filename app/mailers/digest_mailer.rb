class DigestMailer < ApplicationMailer
  def daily_digest(user)
    @user = user
    @new_items = Item.where(status: :available)
                     .where("created_at > ?", 24.hours.ago)
                     .order(created_at: :desc)
                     .limit(20)

    mail(to: @user.email_address, subject: "Your Daily Marketplace Digest")
  end
end
