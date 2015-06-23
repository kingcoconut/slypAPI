module API
  module V1
    class Users < Grape::API
      resource :users do
        desc "Create a user with email and password"
        params do
          requires :email, type: String
          requires :password, type: String
        end
        post do
          user = User.new(declared(params))
          if user.save
            cookies[:user_id] = user.id
            cookies[:api_token] = user.api_token
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
            return user
          else
            error!({
              status: 400,
              messages: user.errors
              }, 400)
          end
        end

        desc "Auth a user"
        params do
          requires :email, type: String
          requires :password, type: String
        end
        post :auth do
          user = User.where(email: params[:email]).first
          if user && user.valid_password?(params[:password])
            cookies[:user_id] = user.id
            cookies[:api_token] = user.api_token
            return
          else
            error!({
              status: 400,
              message: "invalid password or email",
            }, 400)
          end
        end
      end
    end
  end
end