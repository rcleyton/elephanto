# typed: false
# frozen_string_literal: true

class ConfirmationsController < ApplicationController
  allow_unauthenticated_access only: [ :show ]

  def show
    @user = User.find_by(confirmation_token: params[:token])

    if @user && @user.confirmation_sent_at > 2.days.ago
      @user.confirm!
      flash[:success] = t("messages.confirmed_email")
      redirect_to new_session_path
    else
      redirect_to root_path, alert: t("messages.invalid_link")
    end
  end
end
