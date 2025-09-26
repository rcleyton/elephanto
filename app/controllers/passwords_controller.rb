# typed: false
# frozen_string_literal: true

class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  layout "recovery_password"

  def new
  end

  def create
    if params[:email_address].blank?
      flash.now[:alert] = "Email não pode ficar em branco"
      render :new, status: :unprocessable_entity
      return
    end

    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_now
    end

    redirect_to new_session_path, notice: t("messages.reset_instructions")
  end

  def edit
  end

  def update
    case params
    when params[:password]
        flash.now[:alert] = "Senha não pode ficar em branco"
        render :new, status: :unprocessable_entity
    when params[:password_confirmation]
        flash.now[:alert] = "Confirmar senha não pode ficar em branco"
        render :new, status: :unprocessable_entity
    end

    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: t("messages.password_been_reset")
    else
      redirect_to edit_password_path(params[:token]), alert: t("messages.password_not_match")
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: ("messages.password_link_invalid")
  end
end
