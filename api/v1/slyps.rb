module API
  module V1
    class Slyps < Grape::API
      # Authenticate all of these endpoints
      before do
        error!('Unauthorized', 401) unless current_user
      end

      resource :slyps do
        desc "Return all of a users slyps"
        get do
          present current_user.slyps.order('createdon DESC')
        end
      end
    end
  end
end