require_relative 'user.rb'

class SlypChat < ActiveRecord::Base
  has_many :slyp_chat_messages
  has_many :slyp_chat_users
  has_many :users, through: :slyp_chat_users

  class Entity < Grape::Entity
    expose :id
    expose :slyp_chat_messages
    expose :created_at
    expose :slyp_id
    expose :users, using: User::Entity do |slyp_chat, options|
      slyp_chat.users.reject{|u| u.id == options[:env]["api.endpoint"].cookies["user_id"].to_i}
    end
  end
end
