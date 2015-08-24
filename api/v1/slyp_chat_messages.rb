module API
  module V1
    class SlypChatMessages < Grape::API
      # Authenticate all of these endpoints
      before do
        error!('Unauthorized', 401) unless current_user
      end

      resource :slyp_chat_messages do
        desc "Creates a message for the slyp_chat_id"
        params do
          requires :content, type: String
          requires :slyp_chat_id, type: Integer
        end
        post do
          # enforce message is for a valid slyp_chat
          error!("Bad Request", 400) unless slyp_chat = current_user.slyp_chats.where(id: params["slyp_chat_id"]).first
          # enforce message content to not be empty string
          error!("Bad Request", 400) if params["content"].length == 0

          slyp_chat.slyp_chat_messages.create(user_id: current_user.id, content: params["content"])
        end
      end
    end
  end
end