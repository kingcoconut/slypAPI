require_relative 'app'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins 'dev.slyp.io', 'staging.slyp.io', 'alpha.slyp.io'
    resource '*', headers: :any, methods: :get
  end
end
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run API::V1::Base