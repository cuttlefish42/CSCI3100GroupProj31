ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Controller / integration test helpers (auto-included via ActionDispatch::IntegrationTest)
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors, threshold: 500)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
