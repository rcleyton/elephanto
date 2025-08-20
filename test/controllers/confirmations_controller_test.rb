# typed: false
# frozen_string_literal: true

require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "user@elephanto.com.br",
      password: "P@ssword1",
      password_confirmation: "P@ssword1"
    )
    @token = @user.confirmation_token
  end

  context "confirm" do
    it "with valid token" do
      get confirmation_url(token: @token)

      assert_redirected_to new_session_url
      follow_redirect!

      assert_match I18n.t("messages.confirmed_email"), response.body
      @user.reload
      assert @user.confirmed?
    end

    it "not with invalid token" do
      @user.update!(confirmation_sent_at: 3.days.ago)

      get confirmation_url(token: @token)
      assert_redirected_to root_path
      follow_redirect!

      assert_match I18n.t("messages.invalid_link"), response.body
      @user.reload
      refute @user.confirmed?
    end
  end
end
