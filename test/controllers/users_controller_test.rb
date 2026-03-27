# typed: false
# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  it "should use sign_up layout" do
    get sign_up_path
    assert_template layout: "layouts/signup"
  end

  it "creates user and enqueues confirmation email" do
    assert_difference("User.count", 1) do
      assert_enqueued_with(job: ConfirmationEmailJob) do
        post sign_up_path, params: {
          user: {
            email_address: "signup@example.com",
            password: "Password@1",
            password_confirmation: "Password@1",
            terms_of_service: true
          }
        }
      end
    end

    user = User.order(:id).last
    assert_redirected_to new_session_path
    assert_equal I18n.t("messages.create_account"), flash[:success]
    assert user.confirmation_token.present?
  end

  it "re-renders new when user is invalid" do
    assert_no_difference("User.count") do
      post sign_up_path, params: {
        user: {
          email_address: "",
          password: "short",
          password_confirmation: "different",
          terms_of_service: false
        }
      }
    end

    assert_response :unprocessable_entity
    assert_template :new
  end
end
