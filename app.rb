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
mail_options = { :address              => "smtp.gmail.com",
                  :port                 => 587,
                  :domain               => 'slyp.io',
                  :user_name            => 'xander@slyp.io',
                  :password             => 'AlI31ngG94FOLeWVhlmo',
                  :authentication       => 'plain',
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