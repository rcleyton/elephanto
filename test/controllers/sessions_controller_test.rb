# typed: false
# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  it "should use sign_in layout" do
    get new_session_path
    assert_template layout: "layouts/signin"
  end

  context "login" do
    it "should get new session page" do
      get new_session_url
      assert_response :success
    end

    it "should create session with valid credentials" do
      assert_difference "Session.count", 1 do
        post session_url, params: {
          email_address: @user.email_address,
          password: "password"
        }
      end

      assert_redirected_to decks_url
      follow_redirect!
      assert_match "Decks", response.body
    end

    it "should not create session with invalid credentials" do
      assert_no_difference "Session.count" do
        post session_url, params: {
          email_address: @user.email_address,
          password: "wrongpassword"
        }
      end

      assert_redirected_to new_session_path
    end
  end

  context "logout" do
    it "should destroy session on logout" do
      post session_url, params: {
        email_address: @user.email_address,
        password: "password"
      }

      session_id = Session.last.id
      assert Session.exists?(session_id)

      delete session_url

      assert_redirected_to new_session_url
      refute Session.exists?(session_id)
    end
  end
end
