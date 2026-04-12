ENV["RAILS_ENV"] ||= "test"

# Detect if we're running system tests (need :inline adapter for job execution in separate process)
# vs unit/integration tests (need :test adapter for assert_enqueued_jobs)
if ARGV.any? { |arg| arg.include?("test/system/") }
  ENV["SYSTEM_TEST"] = "true"
end

require_relative "../config/environment"
require "rails/test_help"

# Controller / integration test helpers (auto-included via ActionDispatch::IntegrationTest)
require_relative "test_helpers/session_test_helper"

# Testcoverage
require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  primary_coverage :branch
  command_name ENV["SIMPLECOV_NAME"] if ENV["SIMPLECOV_NAME"]
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors, threshold: 500)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
