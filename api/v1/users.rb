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
          new_user = user.created_at > (Time.now - 60)
          SigninWorker.perform_async(user.email, user.regenerate_access_token, new_user)
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
            user.increment!(:sign_in_count)
            user.update_attribute(:ipaddress, request.env['REMOTE_ADDR'])
          end
          redirect UI_DOMAIN
        end

        get :friends do
          error!('Unauthorized', 401) unless current_user
          sql = "select U.id, U.email "\
                "from slyp_chat_users SCU1 "\
                "join slyp_chat_users SCU2 "\
                "on (SCU1.slyp_chat_id = SCU2.slyp_chat_id) "\
                "join users U "\
                "on (SCU2.user_id = U.id) "\
                "where SCU1.user_id = " + current_user.id.to_s + " and SCU2.user_id <> " + current_user.id.to_s + " " +
                "group by U.id, U.email "\
                "order by count(*) desc;"
          present ActiveRecord::Base.connection.select_all(sql)
        end

        get do
          error!('Unauthorized', 401) unless current_user
          present current_user
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