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

    it "already exists" do
      @user = users(:one)
      profile = @user.profile
      post session_url, params: { email_address: @user.email_address, password: "p@ssword1" }

      assert profile.present?
      get new_profile_url

      assert_redirected_to edit_profile_url(profile)
      assert_equal I18n.t("messages.already_exists", model: Profile.model_name.human), flash[:notice]
    end

    it "show" do
      @user = users(:one)
      post session_url, params: { email_address: @user.email_address, password: "p@ssword1" }

      get profile_url(@user.profile)
      assert_response :success

      assert_select "p", text: I18n.t("general.my_profile")
    end

    it "edit" do
      @user = users(:one)
      post session_url, params: { email_address: @user.email_address, password: "p@ssword1" }

      get edit_profile_url(@user.profile)
      assert_response :success

      assert_select "p", text: "#{I18n.t('actions.edit')} #{Profile.model_name.human.downcase}"
    end

    it "update" do
      @user = users(:one)
      post session_url, params: { email_address: @user.email_address, password: "p@ssword1" }

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

    it "should not access another user's profile" do
      other_user = User.create!(
        email_address: "other@example.com",
        password: "p@ssword1",
        password_confirmation: "p@ssword1"
      )

      other_profile = Profile.create!(
        user: other_user,
        first_name: "Invasor",
        last_name: "Invisible",
        username: "ghost",
        bio: "Hacker"
      )

      get edit_profile_url(other_profile)
      assert_redirected_to decks_path
      assert_equal I18n.t("messages.render_not_found"), flash[:alert]
    end
  end
end
