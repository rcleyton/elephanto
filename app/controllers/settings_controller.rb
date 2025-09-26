# typed: false
# frozen_string_literal: true

class SettingsController < ApplicationController
  def show
    @profile = current_user.profile
  end

  def update_password
    if current_user.authenticate(params[:current_password])
      if current_user.update(password_params)
        flash.now[:notice] = "Senha alterada com sucesso."
      else
        flash.now[:alert] = "Erro ao alterar senha: " + current_user.errors.full_messages.join(", ")
      end
    else
      flash.now[:alert] = "Senha atual incorreta."
    end

    render_update_password
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def render_update_password
    render turbo_stream: [
      turbo_stream.update("flash", partial: "shared/flash"),
      turbo_stream.replace("settings_form", partial: "settings/password_form", locals: { user: current_user })
    ]
  end
end
