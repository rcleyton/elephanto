# typed: false
# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t("messages.try_again_later") }
  layout "signin"

  def new
  end

  def create
    @user = User.authenticate_by(params.permit(:email_address, :password))

    if @user
      if @user.verified? == false || !@user.confirmed?
        redirect_to new_session_path, alert: t("messages.confirm_email")
        return
      end

      start_new_session_for @user
      flash[:success] = t("messages.success_login")
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t("messages.incorrect_credentials")
    end
  end

  def destroy
    terminate_session
    flash[:success] = t("messages.success_logout")
    redirect_to root_path
  end
end
