# typed: false
# frozen_string_literal: true

require "test_helper"
require "minitest/rails/capybara"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Capybara.app_host = 'http://app.lvh.me'

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
  end

  register_spec_type(self) do |desc, *addl|
    addl.include? :system
  end
end
