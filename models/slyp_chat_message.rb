class SlypChatMessage < ActiveRecord::Base
  belongs_to :slyp_chat
  belongs_to :user

  class Entity < Grape::Entity
    expose :id
    expose :slyp_chat_id
    expose :user_id
    expose :content
  end
end