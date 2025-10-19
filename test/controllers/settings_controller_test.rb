# typed: false
# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # @profile = @user.create_profile!(learning_speed: 1.0)
      post session_url, params: {  email_address: @user.email_address, password: "P@ssword1" }
  end

  context "Update learning speed" do
    it "with success" do
      patch learning_speed_settings_path, params: { profile: { learning_speed: 1.2 } }, as: :turbo_stream

      assert_response :success
      assert_equal 1.2, @user.profile.reload.learning_speed
      assert_includes response.body, "Configuração de velocidade alterada com sucesso"
    end

    it "must be fail" do
      patch learning_speed_settings_path, params: { profile: { learning_speed: nil } }, as: :turbo_stream

      assert_response :unprocessable_entity
      assert_includes response.body, "Erro ao alterar configuração"
    end
  end
end
