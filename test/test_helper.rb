require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

module ActiveSupport
  class TestCase
    parallel_workers = ENV.fetch("PARALLEL_WORKERS", "1").to_i
    parallelize(workers: parallel_workers) if parallel_workers > 1

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
