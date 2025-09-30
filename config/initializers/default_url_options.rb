Rails.application.config.after_initialize do
  host_config = {
    host: ENV.fetch("APP_HOST", "localhost"),
    protocol: ENV.fetch("APP_PROTOCOL", "http")
  }

  host_config[:port] = ENV["APP_PORT"] if ENV["APP_PORT"].present?

  Rails.application.routes.default_url_options = host_config
  ActionMailer::Base.default_url_options = host_config
  Rails.application.config.action_controller.default_url_options = host_config
end


