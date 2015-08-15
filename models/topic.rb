class Topic < ActiveRecord::Base
  has_many :slyp
  
  class Entity < Grape::Entity
    expose :topic
  end
end