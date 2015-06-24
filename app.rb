require 'grape'
require 'grape_entity'
require 'active_record'
require 'grape/activerecord'
require 'yaml'
require 'pry'

# API
require_relative 'api/v1/users'
require_relative 'api/v1/base'
require_relative 'api/base'

# Models
require_relative 'models/user'

#Configs
ENV['RACK_ENV'] ||= "development"
dbconfig = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[ENV['RACK_ENV']])
ActiveRecord::Base.logger = nil


