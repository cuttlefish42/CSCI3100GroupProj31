require "test_helper"
require "capybara/minitest"
require "selenium/webdriver"
require_relative "system/support/bdd_steps"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include BddSteps

  parallelize(workers: 1)
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
