class ApplicationMailer < ActionMailer::Base
  default from: "noreply@group31.com"
  layout "mailer"
  helper :application
end
