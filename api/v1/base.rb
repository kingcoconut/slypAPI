module API
  module V1
    class Base < Grape::API
      version 'v1'
      format :json

      # global handler for simple not found case
      rescue_from ActiveRecord::RecordNotFound do |e|
        error_response(message: e.message, status: 404)
      end

      # HTTP header based authentication
      # before do
      #   error!('Unauthorized', 401) unless headers['Authorization'] == "some token"
      # end

      helpers do
        def current_user
          # memoize current_user
          @user ||= User.where(id: cookies[:user_id], api_token: cookies[:api_token]).first
        end
      end

      mount API::V1::Users
      mount API::V1::Slyps
      mount API::V1::SlypChats
      mount API::V1::SlypChatMessages
    end
  end
end