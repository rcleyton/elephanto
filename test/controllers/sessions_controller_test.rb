# typed: false
# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "test2@example.com",
      password: "p@ssword1",
      password_confirmation: "p@ssword1"
    )
  end

  it "should use sign_in layout" do
    get new_session_path
    assert_template layout: "layouts/signin"
  end

  it "should use forgot password layout" do
    get new_password_path
    assert_template layout: "layouts/recovery_password"
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
          password: "p@ssword1"
        }
      end

      assert_redirected_to new_profile_url
      follow_redirect!
      assert_match "#{I18n.t('actions.new')} #{Profile.model_name.human.downcase}", response.body
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
        password: "p@ssword1"
      }

      session_id = Session.last.id
      assert Session.exists?(session_id)

      delete session_url

      assert_redirected_to root_url
      refute Session.exists?(session_id)
    end
  end
end
