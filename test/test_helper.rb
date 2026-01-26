require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"

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

class ActionDispatch::IntegrationTest
  setup do
    host! "app.lvh.me"
  end
end
