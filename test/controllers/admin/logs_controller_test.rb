# typed: false
# frozen_string_literal: true

require "test_helper"

class Admin::LogsControllerTest < ActionDispatch::IntegrationTest
  before do
    host! "app.lvh.me"
  end

  it "renders logs page for admins" do
    user = users(:one)

    post session_path, params: { email_address: user.email_address, password: "P@ssword1" }
    get admin_logs_path

    assert_response :success
    assert_template layout: "layouts/admin"
    assert_match "Logs do servidor", response.body
    assert_match "Rails", response.body
  end

  it "redirects non admins" do
    user = users(:one)
    user.update_column(:admin, false)
    user.reload

    post session_path, params: { email_address: user.email_address, password: "P@ssword1" }
    get admin_logs_path

    assert_redirected_to decks_path
  end
end
