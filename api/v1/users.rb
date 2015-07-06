module API
  module V1
    class Users < Grape::API
      resource :users do
        desc "Create a user with email and password"
        params do
          requires :email, type: String
        end
        post do
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
        end
      end
    end
  end
end