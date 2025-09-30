server "64.227.52.217", user: "deploy", roles: %w[app db web]

set :branch, "development"
set :rails_env, "staging"
set :deploy_to, "/var/www/elephanto"
