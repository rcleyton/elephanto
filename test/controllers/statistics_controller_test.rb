# typed: false
# frozen_string_literal: true

require "test_helper"

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: {  email_address: @user.email_address, password: "P@ssword1" }
  end

  context "GET /statistics" do
    it "success" do
      get statistics_path
      assert_response :success
    end
  end
end
