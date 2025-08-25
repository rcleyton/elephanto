# typed: false
# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @confirmation_url = confirmation_url(
      token: @user.confirmation_token,
      email: @user.email_address
    )

    mail(
      to: @user.email_address,
      subject: "Confirme sua conta"
    )
  end
end

