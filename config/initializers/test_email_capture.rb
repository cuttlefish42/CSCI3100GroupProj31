# Capture outgoing emails to disk during tests so system tests can read them
if Rails.env.test?
  require "fileutils"
  require "json"
  require "securerandom"

  module TestEmailCapture
    class Interceptor
      def self.delivering_email(message)
        dir = Rails.root.join("tmp", "test_emails")
        FileUtils.mkdir_p(dir)

        payload = {
          to: Array(message.to),
          subject: message.subject,
          body: (message.body && message.body.decoded) || ""
        }

        filename = dir.join("#{Time.now.utc.strftime('%Y%m%d%H%M%S%6N')}_#{SecureRandom.hex(6)}.json")
        File.write(filename, JSON.generate(payload))
      rescue => e
        Rails.logger.error("TestEmailCapture failed to write email: ")
        Rails.logger.error(e.full_message)
      end
    end
  end

  ActionMailer::Base.register_interceptor(TestEmailCapture::Interceptor)
end
