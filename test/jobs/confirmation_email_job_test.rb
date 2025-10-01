require "test_helper"


class ConfirmationEmailJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "envia email de confirmação" do
    user = users(:one) # ou FactoryBot.create(:user)

    assert_enqueued_with(job: ConfirmationEmailJob, args: [user.id]) do
      ConfirmationEmailJob.perform_later(user.id)
    end

    perform_enqueued_jobs do
      ConfirmationEmailJob.perform_later(user.id)
    end

    assert_emails 1
    mail = ActionMailer::Base.deliveries.last
    assert_equal [user.email_address], mail.to
    assert_match /Confirme sua conta/i, mail.subject
  end
end
