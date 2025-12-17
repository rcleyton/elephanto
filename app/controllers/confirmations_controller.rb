# typed: false
# frozen_string_literal: true

class ConfirmationsController < ApplicationController
  allow_unauthenticated_access only: [ :show, :new, :create ]

  def show
    @user = User.find_by(email_address: params[:email])

    return redirect_to root_path, alert: t("messages.user_not_found") if @user.nil?
    return redirect_to new_session_path, notice: t("messages.already_confirmed") if @user.confirmed?

    if valid_confirmation_link?(@user, params[:token])
      @user.confirm!
      flash[:success] = t("messages.confirmed_email")
      redirect_to new_session_path
    else
      redirect_to new_session_path, alert: t("messages.invalid_link")
    end
  end

  def new
  end

  def create
    @user = User.find_by(email_address: params[:email_address])

    if @user && !@user.confirmed?
      return redirect_to new_confirmation_path, alert: t("messages.confirmation_email_recently_sent") if
      recently_requested_confirmation?(@user)

      @user.generate_confirmation_token
      @user.save(validate: false)

      ConfirmationEmailJob.perform_later(@user.id)

      flash[:success] = t("messages.new_email_to_confirmation")
      redirect_to new_session_path
    else
      redirect_to new_session_path, notice: t("messages.user_not_found_or_confirmed")
    end
  end

  private

  def valid_confirmation_link?(user, token)
    return false unless user.confirmation_token.present? && token.present?
    ActiveSupport::SecurityUtils.secure_compare(user.confirmation_token, token.to_s) &&
      user.confirmation_sent_at > 1.day.ago
  rescue
    false
  end

  def recently_requested_confirmation?(user)
    user.confirmation_sent_at.present? && user.confirmation_sent_at > 5.minutes.ago
  end
end
