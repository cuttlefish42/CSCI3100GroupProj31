class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_USERNAME", "noreply@group31.com")
  layout "mailer"
  helper :application
end
