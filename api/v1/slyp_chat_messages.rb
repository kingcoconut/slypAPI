module API
  module V1
    class SlypChatMessages < Grape::API
      # Authenticate all of these endpoints
      before do
        error!('Unauthorized', 401) unless current_user
      end

      resource :slyp_chat_messages do
        desc "Return all of a users slypchats"
        params do
          requires :content, type: String
          requires :slyp_chat_id, type: Integer
        end
        post do
          error!("Bad Request", 400) unless slyp_chat = current_user.slyp_chats.where(id: params["slyp_chat_id"]).first
          slyp_chat.slyp_chat_messages.create(user_id: current_user.id, content: params["content"])
        end
      end
    end
  end
end