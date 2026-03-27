# typed: false
# frozen_string_literal: true

require "test_helper"

class Landing::PagesControllerTest < ActionDispatch::IntegrationTest
  before do
    host! "lvh.me"
  end

  context "Pages" do
    it "terms" do
      get terms_path

      assert_template layout: "layouts/landing"
      assert_response :success
    end

    it "privacy" do
      get privacy_path

      assert_template layout: "layouts/landing"
      assert_response :success
    end
  end
end
