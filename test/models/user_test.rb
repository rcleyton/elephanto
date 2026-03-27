# typed: false
# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  context "email_address" do
    it "cannot be blank" do
      @user.email_address = ""
      assert_not @user.valid?
      assert_includes @user.errors[:email_address], I18n.t("errors.messages.blank")
    end

    it "must be unique" do
      new_user = User.create(email_address: "user1@elephanto.com", password: "Password@1", password_confirmation: "Password@1")
      assert_not new_user.valid?
      assert_includes new_user.errors[:email_address], I18n.t("errors.messages.taken")
    end

    it "email must be valid" do
      @user.email_address = "foo@bar"
      assert_not @user.valid?
      assert_includes @user.errors[:email_address], I18n.t("errors.messages.invalid")
    end

    it "normalizes email before validation" do
      user = User.create!(
        email_address: "  NEWUSER@Example.COM ",
        password: "Password@1",
        password_confirmation: "Password@1",
        terms_of_service: true
      )

      assert_equal "newuser@example.com", user.email_address
    end
  end

  context "password" do
    it "must have minimum 8 characters" do
      @user.password = "test"
      @user.password_confirmation = "test"
      assert_not @user.valid?
      assert_includes @user.errors[:password], I18n.t("errors.messages.too_short", count: 8)
    end

    it "confirmation must match password" do
      @user.password = "Diferent!"
      @user.password_confirmation = "Different1!"
      assert_not @user.valid?
      assert_includes @user.errors[:password_confirmation], "as senhas não são iguais"
    end

    it "cannot contain spaces" do
      @user.password = "Password 1"
      @user.password_confirmation = "Password 1"
      assert_not @user.valid?
      assert_includes @user.errors[:password], I18n.t("errors.messages.password_contains_whitespace")
    end

    it "password must contain letters, numbers, and special characters" do
      @user.password = "Password1"
      @user.password_confirmation = "Password1"
      assert_not @user.valid?
      assert_includes @user.errors[:password], I18n.t("errors.messages.password_not_complex")
    end

    it "does not require password on unrelated updates" do
      @user.email_address = "updated@elephanto.com"

      assert @user.valid?
    end
  end

  context "confirmation" do
    it "generates confirmation token on create" do
      user = User.create!(
        email_address: "confirm@elephanto.com",
        password: "Password@1",
        password_confirmation: "Password@1",
        terms_of_service: true
      )

      assert user.confirmation_token.present?
      assert user.confirmation_sent_at.present?
      refute user.confirmed?
    end

    it "marks account as confirmed" do
      @user.update_columns(verified: false, confirmed_at: nil, confirmation_token: "token")

      @user.confirm!
      @user.reload

      assert @user.verified?
      assert @user.confirmed_at.present?
      assert_nil @user.confirmation_token
    end
  end
end
