require 'grape'
require 'grape_entity'
require 'active_record'
require 'grape/activerecord'
require 'yaml'
require 'pry'
require 'mail'

# API
require_relative 'api/v1/users'
require_relative 'api/v1/slyps'
require_relative 'api/v1/slyp_chats'
require_relative 'api/v1/slyp_chat_messages'
require_relative 'api/v1/base'
Dir[Dir.pwd + "/api/v1/**/*.rb"].each { |f| require f }
require_relative 'api/base'

# Models
Dir[Dir.pwd + "/models/**/*.rb"].each { |f| require f }

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

