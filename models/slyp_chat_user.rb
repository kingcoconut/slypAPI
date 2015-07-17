class SlypChatUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :slyp_chat
  
  class Entity < Grape::Entity
    expose :id
    expose :user_id
    expose :slyp_chat_id
  end
end