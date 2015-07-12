module API
  module V1
    class SlypChats < Grape::API
      # Authenticate all of these endpoints
      before do
        error!('Unauthorized', 401) unless current_user
      end

      resource :slyp_chats do
        desc "Return all of a users slyps"
        params do
          requires :slyp_id, type: Integer
          requires :emails, type: Array
        end
        post do
          # make sure the slyp belongs to the user
          error!('Bad Request', 400) unless current_user.slyps.where(id: params["slyp_id"]).first
          # create any users that don't already exist
          recipients = params["emails"].map{|email| User.find_or_create_by(email: email)}
          # send the slyps
          recipients.each {|recipient| current_user.send_slyp(params["slyp_id"], recipient.id)}
        end
      end
    end
  end
end