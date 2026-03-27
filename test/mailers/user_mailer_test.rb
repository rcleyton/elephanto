require "test_helper"

describe UserMailer do
  it "builds confirmation email with confirmation link" do
    user = users(:one)
    confirmation_link = Rails.application.routes.url_helpers.confirmation_url(
      token: user.confirmation_token,
      email: user.email_address
    )

    mail = UserMailer.confirmation(user)

    assert_equal [ user.email_address ], mail.to
    assert_equal "Confirme sua conta", mail.subject
    assert_includes mail.body.encoded, CGI.escapeHTML(user.email_address)
    assert_includes mail.body.encoded, CGI.escapeHTML(user.confirmation_token)
    assert_includes mail.body.encoded, CGI.escapeHTML(confirmation_link)
  end
end
