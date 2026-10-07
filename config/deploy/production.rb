server ENV.fetch("DEPLOY_HOST"), user: ENV.fetch("DEPLOY_USER"), roles: %w[app db web]

set :branch, "main"
set :rails_env, "production"
set :deploy_to, "/var/www/elephanto"
