ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"
require "simplecov"

SimpleCov.start "rails" do
  add_filter "app/channels"
  add_filter "app/jobs"
  add_filter "app/mailers"
end

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    class << self
      alias :context :describe
    end
  end
end
