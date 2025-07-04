# typed: false
# frozen_string_literal: true

class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  layout "signup"

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to decks_path, notice: t("messages.create_account")
    else
      flash.now[:alert] = "Erro ao criar conta"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
