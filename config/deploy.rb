lock "~> 3.19.2"

set :application, "elephanto"
set :repo_url, "git@github.com:rcleyton/elephanto.git"

# Diretório no servidor
set :deploy_to, "/var/www/elephanto"

# RVM
set :rvm_type, :user
set :rvm_ruby_version, "3.3.4"

# Linked files (que ficam em shared/)
append :linked_files, "config/database.yml", ".env", "config/master.key"

# Linked dirs (logs, uploads, etc.)
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"
