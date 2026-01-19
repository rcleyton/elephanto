# typed: false
# frozen_string_literal: true

require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  setup do
    @profile = profiles(:one)
    @user    = users(:two)
  end

  context "Profile" do
    it "must be valid" do
      assert @profile.valid?
    end

    it "first_name cannot be blank" do
      @profile.first_name = ""
      assert_not @profile.valid?
    end

    it "last_name cannot be blank" do
      @profile.last_name = ""
      assert_not @profile.valid?
    end

    it "username cannot be blank" do
      @profile.username = ""
      assert_not @profile.valid?
    end

    it "bio cannot be blank" do
      @profile.bio = ""
      assert_not @profile.valid?
    end

    it "should require user" do
      new_profile = Profile.new(first_name: "Jane", last_name: "Doe", username: "silvaclu", bio: "No bio")

      refute new_profile.valid?
      assert_includes new_profile.errors[:user], I18n.t("errors.messages.required")
    end

    it "username should be unique" do
      new_profile = Profile.create(user: @user, first_name: "Ana", last_name: "Silva", username: "silvaclu", bio: "No bio")

      refute new_profile.valid?
      assert_includes new_profile.errors[:username], I18n.t("errors.messages.taken")
    end
  end

  context "Limit" do
    it "max new per day cannot be blank" do
      @profile.daily_new_limit = ""

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_new_limit], I18n.t("errors.messages.blank")
    end

    it "max new review per day cannot be blank" do
      @profile.daily_review_limit = ""

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_review_limit], I18n.t("errors.messages.blank")
    end

    it "daily new flashacards must be an integer positive" do
      @profile.daily_new_limit = "20.5"

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_new_limit], "não é um número inteiro"
    end

    it "daily reviews must be positive" do
      @profile.daily_review_limit = "20.5"

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_review_limit], "não é um número inteiro"
    end

    it "max new per day must be greater than 0" do
      @profile.daily_new_limit = 0

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_new_limit], "deve ser maior que 0"
    end

    it "max review per day must be greater than 0" do
      @profile.daily_review_limit = 0

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_review_limit], "deve ser maior que 0"
    end

    it "daily reviews cannot exceed 100" do
      @profile.daily_review_limit = 101

      assert_not @profile.valid?
      assert_includes @profile.errors[:daily_review_limit], "deve ser menor ou igual a 100"
    end
  end
end
