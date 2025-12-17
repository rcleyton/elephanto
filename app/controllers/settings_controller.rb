# typed: false
# frozen_string_literal: true

class SettingsController < ApplicationController
  include ProfileRequired

  before_action :required_profile, only: [ :show ]

  def show
    @profile = current_user.profile
  end

  def update_password
    if current_user.authenticate(params[:current_password])
      if current_user.update(password_params)
        flash.now[:notice] = "Senha alterada com sucesso."

        render turbo_stream: [
          turbo_stream.update("flash", partial: "shared/flash"),
          turbo_stream.replace("password_settings_form", partial: "settings/password_form", locals: { user: current_user })
        ]
      else
        flash.now[:alert] = "Erro ao alterar senha: " + current_user.errors.full_messages.join(", ")
        render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Senha atual incorreta."
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :unprocessable_entity
    end
  end

  def learning_speed
    @profile = current_user.profile

    if @profile.update(learning_speed_params)
      flash.now[:notice] = "Configuração de velocidade alterada com sucesso!"
      render turbo_stream: [
        turbo_stream.update("flash", partial: "shared/flash"),
        turbo_stream.replace("learning_speed_form", partial: "settings/learning_speed", locals: { user: current_user })
      ]
    else
      flash.now[:alert] = "Erro ao alterar configuração."
      render turbo_stream: [
        turbo_stream.update("flash", partial: "shared/flash"),
        turbo_stream.replace("learning_speed_form", partial: "settings/learning_speed", locals: { user: current_user })
      ], status: :unprocessable_entity
    end
  end

  def delete_account
    if current_user.profile.username == params[:username]
      if current_user.authenticate(params[:current_password])
        current_user.destroy
        flash[:success] = "Conta excluída com sucesso!"
        redirect_to root_path
      else
        flash.now[:alert] = "Senha incorreta."
        render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Nome de usuário incorreto."
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :unprocessable_entity
    end
  end

  def remove_deck
    deck = current_user.decks.find(params[:deck_id])

    if deck.destroy
      flash.now[:success] = "Deck apagado!"

      render turbo_stream: [
        turbo_stream.update("flash", partial: "shared/flash"),
        turbo_stream.replace(
          "remove_deck_form",
          partial: "settings/remove_deck",
          locals: { user: current_user }
        )
      ]
    else
      flash.now[:alert] = "Erro ao excluir deck"

      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"),
            status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Deck inválido"
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"),
           status: :not_found
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def learning_speed_params
    params.require(:profile).permit(:learning_speed)
  end
end
