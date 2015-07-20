require_relative 'user.rb'

class SlypChat < ActiveRecord::Base
  has_many :slyp_chat_messages
  has_many :slyp_chat_users
  has_many :users, through: :slyp_chat_users

  class Entity < Grape::Entity
    expose :id
    expose :slyp_chat_messages
    expose :created_at
    expose :users, using: User::Entity
  end
end