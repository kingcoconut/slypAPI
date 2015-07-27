require 'grape'
require 'grape_logging'
require 'grape_entity'
require 'active_record'
require 'grape/activerecord'
require 'yaml'
require 'pry'
require 'mail'
require 'newrelic_rpm'
require 'newrelic-grape'

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

# Services
Dir[Dir.pwd + "/services/**/*.rb"].each { |f| require f }

# Configs
ENV['RACK_ENV'] ||= "development"
dbconfig = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[ENV['RACK_ENV']])
ActiveRecord::Base.logger = nil

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