# typed: false
# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
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

  context "Delete" do
    it "account" do
      assert_difference("User.count", -1) do
        delete delete_account_settings_path(@user), params: {
          username: @user.profile.username,
          current_password: "P@ssword1"
        }
      end

      assert_redirected_to root_path
      follow_redirect!
      assert_equal "Conta excluída com sucesso!", flash[:success]
    end

    it "fails with wrong username" do
      assert_no_difference("User.count") do
        delete delete_account_settings_path(@user), params: {
          username: "wrong",
          current_password: "P@ssword1"
        }
      end

      assert_response :unprocessable_entity
      assert_equal "Nome de usuário incorreto.", flash[:alert]
    end

    it "fails with wrong password" do
      assert_no_difference("User.count") do
        delete delete_account_settings_path(@user), params: {
          username: @user.profile.username,
          current_password: "wrong_password"
        }
      end

      assert_response :unprocessable_entity
      assert_equal "Senha incorreta.", flash[:alert]
    end
  end
end
