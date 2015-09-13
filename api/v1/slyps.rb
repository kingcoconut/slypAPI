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
        get "slyps/:id" do
          error!("Bad Request", 400) unless slyp = current_user.slyps.find_by(params["id"])
          present slyp
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
        desc "Mark user_slyps.starred record as true"
        put "slyps/starred/:id" do
          error!("Bad Request", 400) unless user_slyp = UserSlyp.where(user_id: current_user.id, slyp_id: params["id"]).first
          user_slyp.update_attribute(:starred, true)
        end
        desc "Mark user_slyps.starred record as false"
        put "slyps/unstarred/:id" do
          error!("Bad Request", 400) unless user_slyp = UserSlyp.where(user_id: current_user.id, slyp_id: params["id"]).first
          user_slyp.update_attribute(:starred, false)
        end
        desc "Mark user_slyps.archived record as true"
        put "slyps/archived/:id" do
          error!("Bad Request", 400) unless user_slyp = UserSlyp.where(user_id: current_user.id, slyp_id: params["id"]).first
          user_slyp.update_attribute(:archived, true)
        end
        desc "Mark user_slyps.archived record as false"
        put "slyps/unarchived/:id" do
          error!("Bad Request", 400) unless user_slyp = UserSlyp.where(user_id: current_user.id, slyp_id: params["id"]).first
          user_slyp.update_attribute(:archived, false)
        end
    end
  end
end