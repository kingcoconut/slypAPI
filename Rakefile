require 'bundler/setup'
require 'grape/activerecord/rake'

ENV['RACK_ENV'] ||= "development"
require './app'

namespace :db do
  # Some db tasks require your app code to be loaded
  task :environment do

  end
end

namespace :users do
  task :generate_icons do
    User.all.each do |user|
      user.update_attribute(:icon_url, IconService.generate_random)
    end
  end
end

namespace :email do
  desc 'send digest email'
  task :send_digest_email do
    EmailDigestWorker.perform_async
  end
end