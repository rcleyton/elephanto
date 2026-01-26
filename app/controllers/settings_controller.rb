# typed: false
# frozen_string_literal: true

class SettingsController < ApplicationController
  include ProfileRequired

  before_action :required_profile, only: [ :show ]
  before_action :load_profile, only: %i[ show rigor_factor daily_limit ]

  def show; end

  def change_password
    if current_user.authenticate(params[:current_password])
      if current_user.update(password_params)
        success_update("Senha alterada com sucesso.", "change_password_form", partial: "settings/change_password")
      else
        flash.now[:error] = "Erro ao alterar a senha."
        render_turbo_updates("change_password_form", "settings/change_password", status: :unprocessable_entity)
      end
    else
      current_user.errors.add(:current_password, "está incorreta")
      flash.now[:error] = "Senha atual incorreta."
      render_turbo_updates("change_password_form", "settings/change_password", status: :unprocessable_entity)
    end
  end

  def rigor_factor
    if @profile.update(rigor_factor_params)
      success_update("Configuração de velocidade alterada com sucesso!", "rigor_factor")
    else
      error_update("Erro ao alterar configuração.", "rigor_factor")
    end
  end

  def daily_limit
    if @profile.update(review_settings_params)
      success_update("Limites diários atualizados!", "review_settings_form", partial: "settings/review_settings")
    else
      error_update("Erro ao atualizar limites diários.", "review_settings_form", partial: "settings/review_settings")
    end
  end

  def delete_account
    if username_matches? && current_user.authenticate(params[:current_password])
      current_user.destroy
      flash[:success] = "Conta excluída com sucesso!"
      redirect_to root_path
    else
      error_message(error_message_for_delete_account)
    end
  end

  def remove_deck
    deck = current_user.decks.find_by(id: params[:deck_id])

    if deck&.destroy
      success_update("Deck apagado!", "remove_deck_form", partial: "settings/remove_deck")
    else
      error_message(deck ? "Erro ao excluir deck" : "Deck inválido", status: deck ? :unprocessable_entity : :not_found)
    end
  end

  private

  def load_profile
    @profile = current_user.profile
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def rigor_factor_params
    params.require(:profile).permit(:rigor_factor)
  end

  def review_settings_params
    params.require(:profile).permit(:daily_new_limit, :daily_review_limit, :rigor_factor)
  end

  def success_update(success_message, form_id, partial: "settings/#{form_id}")
    flash.now[:success] = success_message
    render_turbo_updates(form_id, partial)
  end

  def error_update(alert_message, form_id, partial: "settings/#{form_id}")
    flash.now[:error] = alert_message
    render_turbo_updates(form_id, partial, status: :unprocessable_entity)
  end

  def error_message(alert_message, status: :unprocessable_entity)
    flash.now[:error] = alert_message
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: status
  end

  def render_turbo_updates(form_id, partial_path, status: :ok)
    render turbo_stream: [
      turbo_stream.update("flash", partial: "shared/flash"),
      turbo_stream.replace(form_id, partial: partial_path, locals: { current_user: current_user })
    ], status: status
  end

  def username_matches?
    p current_user.profile.username == params[:username]
  end

  def error_message_for_delete_account
    username_matches? ? "Senha incorreta." : "Nome de usuário incorreto."
  end
end
