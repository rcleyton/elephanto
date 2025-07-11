# typed: false
# frozen_string_literal: true

require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)

    post session_url, params: { email_address: @user.email_address, password: "p@ssword1" }
  end

  it "shoud get new" do
    get new_profile_url
    assert_response :success
  end

  context "profile" do
    it "create" do
      assert_difference("Profile.count", 1) do
        post profiles_url, params: { profile: { first_name: "Jane", last_name: "Doe", username: "jane", bio: "No bio" } }
      end

      assert_redirected_to profile_url(@user.profile)
      assert_equal I18n.t("messages.created", model: Profile.model_name.human), flash[:notice]
    end

    it "show" do
      @user = users(:one)
      get profile_url(@user.profile)
      assert_response :success

      assert_select "h1", text: "Show Profile"
    end

    it "edit" do
      @user = users(:one)
      get edit_profile_url(@user.profile)
      assert_response :success

      assert_select "p", text: "#{I18n.t('actions.edit')} #{Profile.model_name.human.downcase}"
    end

    it "update" do
      @user = users(:one)
      profile = @user.profile

      updated_attributes = {
        first_name: "Cleyton Roberto",
        last_name: "da Silva",
        username: "silvaclu",
        bio: "This is an updated bio."
      }

      patch profile_url(profile), params: { profile: updated_attributes }

      assert_redirected_to profile_url(profile)
      assert_equal I18n.t("messages.updated", model: Profile.model_name.human), flash[:notice]

      profile.reload
      assert_equal "Cleyton Roberto", profile.first_name
      assert_equal "da Silva", profile.last_name
      assert_equal "silvaclu", profile.username
      assert_equal "This is an updated bio.", profile.bio
    end
  end
end
