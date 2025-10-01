class ConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.confirmation(user).deliver_now
  end
end
