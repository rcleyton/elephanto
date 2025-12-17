# typed: false
# frozen_string_literal: true

require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "user@elephanto.com.br",
      password: "P@ssword1",
      password_confirmation: "P@ssword1",
      terms_of_service: true
    )
    @token = @user.confirmation_token
  end

  context "confirm" do
    it "with valid token" do
      get confirmation_url(token: @token, email: @user.email_address)

      assert_redirected_to new_session_url
      follow_redirect!

      assert_match I18n.t("messages.confirmed_email"), response.body
      @user.reload
      assert @user.confirmed?
    end

    it "already confirmed" do
      @user.update(verified: true, confirmation_token: nil, confirmed_at: Time.current)
      @user.reload

      get confirmation_url(token: @token, email: @user.email_address)

      assert_redirected_to new_session_url
      follow_redirect!

      assert_match I18n.t("messages.already_confirmed"), response.body
      assert @user.confirmed?
    end

    it "redirects when email does not exist" do
      post confirmation_url, params: { email_address: "notfound@elephanto.com.br" }

      assert_redirected_to new_session_path
      assert_equal I18n.t("messages.user_not_found_or_confirmed"), flash[:notice]
    end

    it "does not confirm with wrong email" do
      get confirmation_url(token: @token, email: "wrong@elephanto.com.br")

      assert_redirected_to root_url
      assert_equal I18n.t("messages.user_not_found"), flash[:alert]
      refute @user.reload.confirmed?
    end
  end

  context "resend" do
    it "new confirmation" do
      get new_confirmation_path
      assert :success
    end

    it "not with invalid token" do
      @user.update(confirmation_sent_at: 3.days.ago)

      get confirmation_path(token: @token, email: @user.email_address)
      assert_redirected_to new_session_path
      follow_redirect!

      expected_message = I18n.t("messages.invalid_link")
      assert_equal expected_message, flash[:alert]
      @user.reload
      refute @user.confirmed?
    end

    it "email to confirm user with new token" do
      post confirmation_url, params: { email_address: @user.email_address }
      @user.reload

      get confirmation_url(token: @user.confirmation_token, email: @user.email_address)

      assert_redirected_to new_session_url
      assert_equal I18n.t("messages.confirmed_email"), flash[:success]
      assert @user.reload.confirmed?
    end

    it "does not resend if user already confirmed" do
      @user.update!(verified: true, confirmed_at: Time.current)

      assert_no_emails do
        post confirmation_url, params: { email_address: @user.email_address }
      end

      assert_redirected_to new_session_path
      assert_equal I18n.t("messages.user_not_found_or_confirmed"), flash[:notice]
    end

    it "should enqueue confirmation email if last sent more than 5 minutes ago" do
      @user.update!(confirmation_sent_at: 10.minutes.ago)

      assert_enqueued_with(job: ConfirmationEmailJob, args: [ @user.id ]) do
        post confirmation_path, params: { email_address: @user.email_address }
      end

      assert_redirected_to new_session_path
      assert_equal I18n.t("messages.new_email_to_confirmation"), flash[:success]
    end

    it "should not enqueue email if last sent less than 5 minutes ago" do
      @user.update!(confirmation_sent_at: 2.minutes.ago)

      assert_no_enqueued_jobs do
        post confirmation_path, params: { email_address: @user.email_address }
      end

      assert_redirected_to new_confirmation_path
      assert_equal I18n.t("messages.confirmation_email_recently_sent"), flash[:alert]
    end
  end
end
