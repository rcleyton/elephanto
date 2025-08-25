# typed: false
# frozen_string_literal: true

class ConfirmationsController < ApplicationController
  allow_unauthenticated_access only: [ :show, :create ]

  def show
    @user = User.find_by(email_address: params[:email])

    if @user.nil?
      redirect_to root_path, alert: t("messages.user_not_found") and return
    end

    if @user.confirmed?
      redirect_to new_session_path, notice: t("messages.already_confirmed") and return
    end

    if @user.confirmation_token == params[:token] && @user.confirmation_sent_at > 1.day.ago
      @user.confirm!
      flash[:success] = t("messages.confirmed_email")
      redirect_to new_session_path
    else
      redirect_to root_path(resend_user_id: @user.id), alert: t("messages.invalid_link")
    end
  end

  def create
    @user = User.find_by(email_address: params[:email_address])

    if @user && !@user.confirmed?
      @user.generation_confirmation_token
      @user.save(validate: false)
      UserMailer.confirmation(@user).deliver_now

      flash[:success] = t("messages.new_email_to_confirmation")
    else
      redirect_to root_path, notice: t("messages.user_not_found_or_confirmed")
    end
  end
end
