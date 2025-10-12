# typed: false
# frozen_string_literal: true

require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  before do
    host! "app.lvh.me"
  end

  context "Admin"  do
    it 'get success' do
      @user = users(:one)
      post session_url, params: {  email_address: @user.email_address, password: "P@ssword1" }
      
      get admin_path

      assert_template layout: "layouts/admin"
      assert :success
    end
  end
end
