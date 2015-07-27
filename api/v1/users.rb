require 'open-uri'

module API
  module V1
    class Users < Grape::API
      resource :users do
        desc "Create a user with email and password"
        params do
          requires :email, type: String
        end
        post do
          user = User.find_or_create_by(email: params["email"])
          email = user.email
          access_token = user.regenerate_access_token
          mail = Mail.deliver do
            from "Slyp <no-reply@slyp.io>"
            to email
            subject "Slyp Test"
            html_part do
              content_type 'text/html; charset=UTF-8'
              body "Slyp this up your <a href='http://meatspin.com'>pooper</a> then go <a href='#{API_DOMAIN}/v1/users/auth?email=#{CGI.escape(email)}&access_token=#{access_token}'>here</a>"
            end
          end
        end

        desc "Creates a user with an email and facebook_id"
        params do
          requires :email, type: String
          requires :facebook_id, type: String
        end
        post :facebook do
          user = User.new(declared(params))
          if user.save
            set_user_cookies(user)
            return user
          else
            error!({
              status: 400,
              messages: user.errors
              }, 400)
          end
        end

        get :auth do
          if user = User.where(email: params["email"], access_token: params["access_token"]).first
            set_user_cookies(user)
          end
          redirect UI_DOMAIN
        end
      end

      helpers do
        def set_user_cookies(user)
          cookies[:user_id] = {
            value: user.id,
            expires: Time.now + 10.years,
            domain: '.slyp.io',
            path: '/'
          }
          cookies[:api_token] = {
            value: user.api_token,
            expires: Time.now + 10.years,
            domain: '.slyp.io',
            path: '/'
          }
          cookies[:email] = {
            value: user.email,
            expires: Time.now + 10.years,
            domain: '.slyp.io',
            path: '/'
          }
        end
      end
    end
  end
end