require_relative "simplecov_helper"

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"
require "simplecov"

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

Minitest.after_run { SimpleCov.result.format! }
