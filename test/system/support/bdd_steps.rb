require "json"

module BddSteps
  def given(description = nil)
    Rails.logger.debug("GIVEN #{description}") if description
    yield
  end

  def when_(description = nil)
    Rails.logger.debug("WHEN #{description}") if description
    yield
  end

  def then_(description = nil)
    Rails.logger.debug("THEN #{description}") if description
    yield
  end

  def last_email
    # Prefer disk-backed captured emails (useful when app server runs in different thread/process)
    dir = Rails.root.join("tmp", "test_emails")
    if Dir.exist?(dir)
      files = Dir[dir.join("*.json")]
      if files.any?
        latest = files.max_by { |f| File.mtime(f) }
        begin
          data = JSON.parse(File.read(latest))
          return TestEmailWrapper.new(data)
        rescue => e
          Rails.logger.error "Failed to read test email file: #{e.message}"
        end
      end
    end

    ActionMailer::Base.deliveries.last
  end

  def clear_emails
    dir = Rails.root.join("tmp", "test_emails")
    if Dir.exist?(dir)
      Dir[dir.join("*.json")].each { |f| File.delete(f) rescue nil }
    end
    ActionMailer::Base.deliveries.clear
  end

  def delivered_emails_count
    mem = ActionMailer::Base.deliveries.count
    dir = Rails.root.join("tmp", "test_emails")
    disk = Dir.exist?(dir) ? Dir[dir.join("*.json")].length : 0
    [mem, disk].max
  end
  
end

class TestEmailWrapper
  def initialize(hash)
    @h = hash
  end

  def to
    @h["to"]
  end

  def subject
    @h["subject"]
  end

  def body
    Body.new(@h["body"])
  end

  class Body
    def initialize(text)
      @text = text || ""
    end

    def encoded
      @text
    end

    def decoded
      @text
    end
  end
end
