class ApplicationMailer < ActionMailer::Base
  default from: "noreply@group31.com"
  layout "mailer"
  helper :application
  
  # Capture mail payload at creation time for system tests (so the test process
  # can inspect email contents even if deliver_later is used and runs in another context)
  if Rails.env.test?
    require "fileutils"
    require "json"
    require "securerandom"
    def mail(headers = {}, &block)
      message = super
      begin
        dir = Rails.root.join("tmp", "test_emails")
        FileUtils.mkdir_p(dir)
        payload = {
          to: Array(message.to),
          subject: message.subject,
          body: (message.body && message.body.decoded) || ""
        }
        filename = dir.join("created_#{Time.now.utc.strftime('%Y%m%d%H%M%S%6N')}_#{SecureRandom.hex(6)}.json")
        File.write(filename, JSON.generate(payload))
      rescue => e
        Rails.logger.error("ApplicationMailer test capture failed: #{e.message}")
      end
      message
    end
  end
end
