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
      UserMailer.confirmation(@user).deliver_now
      flash[:success] = t("messages.create_account")
      redirect_to root_path
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :terms_of_service)
  end
end
