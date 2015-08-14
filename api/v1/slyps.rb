module API
  module V1
    class Slyps < Grape::API
      # Authenticate all of these endpoints
      before do
        error!('Unauthorized', 401) unless current_user
      end

      # resource :slyps do
        desc "Return all of a users slyps"
        get "slyps" do
          present current_user.slyps.order('created_at DESC')
        end

        desc "Delete user_slyp record from user_slyp table"
        delete "slyps/:id" do
          error!("Bad Request", 400) unless user_slyp = UserSlyp.where(user_id: current_user.id, slyp_id: params["id"]).first
          user_slyp.delete()
        end
        desc "Mark user_slyps.engaged record as true"
        put "slyps/engaged/:id" do 
          error!("Bad Request", 400) unless user_slyp = UserSlyp.where(user_id: current_user.id, slyp_id: params["id"]).first
          user_slyp.update_attribute(:engaged, true)
        end
    end
  end
end