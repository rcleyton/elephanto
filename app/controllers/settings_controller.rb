# typed: false
# frozen_string_literal: true

class SettingsController < ApplicationController
  include ProfileRequired

  before_action :set_profile, only: [ :show, :rigor_factor, :daily_limit ]

  def show; end

  def update_password
    if current_user.authenticate(params[:current_password])
      if current_user.update(password_params)
        success_update("Senha alterada com sucesso.", "password_settings_form")
      else
        error_update(current_user.errors.full_messages.join(", "), "password_settings_form")
      end
    else
      error_message("Senha atual incorreta.")
    end
  end

  def rigor_factor
    if @profile.update(rigor_factor_params)
      success_update("Configuração de velocidade alterada com sucesso!", "rigor_factor_form")
    else
      error_update("Erro ao alterar configuração.", "rigor_factor_form")
    end
  end

  def daily_limit
    if @profile.update(review_settings_params)
      success_update("Limites diários atualizados!", "review_settings_form")
    else
      error_update("Erro ao atualizar limites diários.", "review_settings_form")
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

  def set_profile
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

  # Métodos auxiliares para reduzir duplicação

  def success_update(notice_message, form_id, partial: "settings/#{form_id}")
    flash.now[:notice] = notice_message
    render_turbo_updates(form_id, partial)
  end

  def error_update(alert_message, form_id, partial: "settings/#{form_id}")
    flash.now[:alert] = alert_message
    render_turbo_updates(form_id, partial, status: :unprocessable_entity)
  end

  def error_message(alert_message, status: :unprocessable_entity)
    flash.now[:alert] = alert_message
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: status
  end

  def render_turbo_updates(form_id, partial_path, status: :ok)
    render turbo_stream: [
      turbo_stream.update("flash", partial: "shared/flash"),
      turbo_stream.replace(form_id, partial: partial_path, locals: { user: current_user })
    ], status: status
  end

  def username_matches?
    current_user.profile.username == params[:username]
  end

  def error_message_for_delete_account
    username_matches? ? "Senha incorreta." : "Nome de usuário incorreto."
  end
end
