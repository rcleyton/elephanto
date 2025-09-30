# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# SCM
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Bundler
require "capistrano/bundler"

# Rails
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

# RVM e Passenger
require "capistrano/rvm"
require "capistrano/passenger"

# Custom tasks
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
