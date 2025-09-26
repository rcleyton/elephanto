# typed: false
# frozen_string_literal: true

require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  it "success" do
    get new_password_path
    assert :success
  end

  it "sends reset instructions" do
    user = User.create!(
      email_address: "test@example.com",
      password: "p@ssword1",
      password_confirmation: "p@ssword1",
      terms_of_service: true
    )
    post passwords_path, params: { email_address: user.email_address }

    assert_redirected_to new_session_path
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

