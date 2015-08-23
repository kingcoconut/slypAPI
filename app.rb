require 'grape'
require 'grape_entity'
require 'active_record'
require 'grape/activerecord'
require 'yaml'
require 'pry'
require 'mail'
require 'newrelic_rpm'
require 'newrelic-grape'
require 'sidekiq'

# API
require './api/v1/users'
require './api/v1/slyps'
require './api/v1/slyp_chats'
require './api/v1/slyp_chat_messages'
require './api/v1/base'
Dir[Dir.pwd + "/api/v1/**/*.rb"].each { |f| require f }
require './api/base'

# Models
Dir[Dir.pwd + "/models/**/*.rb"].each { |f| require f }

# Workers
Dir[Dir.pwd + "/workers/**/*.rb"].each { |f| require f }

# Services
Dir[Dir.pwd + "/services/**/*.rb"].each { |f| require f }

# CONFIGURATIONS
ENV['RACK_ENV'] ||= "development"

# DB config
dbconfig = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[ENV["RACK_ENV"]])
ActiveRecord::Base.logger = nil

#Domain
domains = YAML::load(File.open('config/domains.yml'))[ENV["RACK_ENV"]]
UI_DOMAIN = domains["ui"]
API_DOMAIN = domains["api"]

# Email Configs
mailer = YAML::load(File.open('config/mailer.yml'))[ENV["RACK_ENV"]]
mail_options = { :address              => mailer["address"],
                  :port                 => mailer["port"],
                  :domain               => mailer["domain"],
                  :user_name            => mailer["user_name"],
                  :password             => mailer["password"],
                  :authentication       => mailer["authentication"],
                  :enable_starttls_auto => true
                }
Mail.defaults do
  delivery_method :smtp, mail_options
end

# REDIS CONFIG
# Sidekiq.configure_server do |config|
#   config.redis = { url: 'redis://redis.example.com:7372/12' }
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: 'redis://redis.example.com:7372/12' }
# end