server "64.227.52.217", user: "deploy", roles: %w[app db web]

set :branch, "main"
set :rails_env, "production"
set :deploy_to, "/var/www/elephanto"
