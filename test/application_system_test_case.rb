require "test_helper"
require "capybara/minitest"
require "selenium/webdriver"
require_relative "system/support/bdd_steps"
require_relative "system/support/setup_helper"

Capybara.disable_animation = true
Capybara.automatic_label_click = true

Capybara.register_driver(:custom_headless_chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--window-size=1400,1400")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  # stupid passwordleak popup
  options.add_argument("--disable-features=PasswordLeakDetection,PasswordCheck,SafeBrowsingEnhancedProtection")
  options.add_preference(:credentials_enable_service, false)
  options.add_preference(:profile, { password_manager_enabled: false, password_manager_leak_detection: false })
  options.add_argument("--headless=new")
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include BddSteps
  include SetupHelper
  include ActiveJob::TestHelper

  # Switch to :inline adapter for system tests since they run in a separate server process
  # The default :test adapter won't work across processes
  setup do
    @original_queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
  end

  teardown do
    ActiveJob::Base.queue_adapter = @original_queue_adapter
  end

  parallelize(workers: 1)
  driven_by :custom_headless_chrome
end
