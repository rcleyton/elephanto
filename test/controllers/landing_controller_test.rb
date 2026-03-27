# typed: false
# frozen_string_literal: true

require "test_helper"

class LandingControllerTest < ActionDispatch::IntegrationTest
  it "should user landing page layout" do
    host! "lvh.me"

    get root_path

    assert_response :success
    assert_template layout: "layouts/landing"
  end
end
