# typed: false
# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  it "should use sign_up layout" do
    get sign_up_path
    assert_template layout: "layouts/signup"
  end
end
