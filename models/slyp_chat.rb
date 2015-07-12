class SlypChat < ActiveRecord::Base
  has_many :slyp_chat_users
  has_many :users, through: :slyp_chat_users

  class Entity < Grape::Entity
    expose :id
  end
end