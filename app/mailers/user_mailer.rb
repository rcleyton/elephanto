# typed: false
# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @token = @user.confirmation_token

    mail to: @user.email_address, subject: "Confirme sua conta"
  end
end
