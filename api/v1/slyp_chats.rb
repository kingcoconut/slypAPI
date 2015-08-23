module API
  module V1
    class SlypChats < Grape::API
      # Authenticate all of these endpoints
      before do
        error!('Unauthorized', 401) unless current_user
      end

      resource :slyp_chats do
        desc "Send a slyp to multiple users"
        params do
          requires :slyp_id, type: Integer
          requires :emails, type: Array
        end
        post do
          # make sure the slyp belongs to the user
          error!('Bad Request', 400) unless current_user.slyps.where(id: params["slyp_id"]).first

          #validate all emails
          params["emails"].each {|email| error!('Bad Request', 400) if email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i).nil?}

          # create any users that don't already exist
          recipients = params["emails"].map{|email| User.find_or_create_by(email: email)}
          # send the slyps

          new_chats = recipients.map {|recipient| current_user.send_slyp(params["slyp_id"], recipient.id, current_user.id)}
          present new_chats
        end

        desc "Return all slyp chats for a slyp"
        params do
          requires :slyp_id, type: Integer
        end
        get do
          error!('Not Found', 404) unless UserSlyp.where(user_id: current_user.id, slyp_id: params["slyp_id"]).first
          present current_user.slyp_chats.where(slyp_id: params["slyp_id"])
        end

        desc "Update slyp_chat_user.last_read_at record"
        params do
          requires :slyp_chat_id, type: Integer
        end
        post :read do
          error!('Not Found', 404) unless SlypChatUser.where(user_id: current_user.id, id: params["slyp_chat_id"]).first
          current_user.slyp_chat_users.find_by(slyp_chat_id: params["slyp_chat_id"]).update(last_read_at: Time.now)
        end

      end
    end
  end
end