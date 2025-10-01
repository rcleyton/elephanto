require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false

  config.action_controller.perform_caching = true

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.active_storage.service = :local

  config.assume_ssl = true

  config.force_ssl = true

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"

  config.active_support.report_deprecations = false

  config.cache_store = :solid_cache_store

  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  
  config.action_mailer.default_url_options = { host: "getelephanto.com" }
  
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              "smtp-relay.brevo.com",
    port:                 587,
    domain:               "getelephanto.com",
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    authentication:       "plain",
    enable_starttls_auto: true,
    open_timeout:         20,
    read_timeout:         20
  }

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  config.action_controller.default_url_options = { host: "app.getelephanto.com", protocol: "https" }

  config.hosts << "getelephanto.com"
  config.hosts << "app.getelephanto.com"
end
