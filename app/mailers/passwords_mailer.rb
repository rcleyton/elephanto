class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t('messages.reset_your_password'), to: user.email_address
  end
end
