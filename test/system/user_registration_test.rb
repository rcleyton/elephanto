# typed: false
# frozen_string_literal: true

require "application_system_test_case"

class UserRegistrationTest < ApplicationSystemTestCase
  it "user can sign up with valid data" do
    visit sign_up_path

    fill_in  I18n.t("placeholders.user.email_address"), with: "test2@example.com"
    fill_in  I18n.t("placeholders.user.password"), with: "p@ssword1"
    fill_in  I18n.t("placeholders.user.password_confirmation"), with: "p@ssword1"
    click_on I18n.t("buttons.submit.create_account")

    assert_text I18n.t("messages.create_account")
  end
end
