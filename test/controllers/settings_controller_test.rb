# typed: false
# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: {  email_address: @user.email_address, password: "P@ssword1" }
  end

  context "Update rigor factor" do
    it "with success" do
      patch rigor_factor_settings_path, params: { profile: { rigor_factor: 9.0 } }, as: :turbo_stream

      assert_response :success
      assert_equal 9.0, @user.profile.reload.rigor_factor
      assert_includes response.body, "Configuração de velocidade alterada com sucesso"
    end

    it "must be fail" do
      patch rigor_factor_settings_path, params: { profile: { rigor_factor: nil } }, as: :turbo_stream

      assert_response :unprocessable_entity
      assert_includes response.body, "Erro ao alterar configuração"
    end
  end

  context "Delete account" do
    it "with success" do
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

  context "Delete deck" do
    it "with success" do
      deck = @user.decks.first

      assert_difference("Deck.count", -1) do
        delete remove_deck_settings_path(deck), params: {
          deck_id: deck.id
        }
      end

      assert_equal "Deck apagado!", flash[:success]
    end

    it "must prevent deletion if deck belongs to other user" do
      other_deck        = decks(:chemical)
      deck_count_before = Deck.count

      delete remove_deck_settings_path(other_deck), params: {
        deck_id: other_deck.id
      }

      assert_equal "Deck inválido", flash[:alert]
      assert_response :not_found
      assert_equal deck_count_before, Deck.count
    end
  end
end
