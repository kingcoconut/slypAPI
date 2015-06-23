require 'bundler/setup'
require 'grape/activerecord/rake'

namespace :db do
  # Some db tasks require your app code to be loaded
  task :environment do
    require_relative 'app'
  end
end