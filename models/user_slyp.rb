class UserSlyp < ActiveRecord::Base
  belongs_to :user
  belongs_to :slyp
  validates_uniqueness_of :user_id, scope: :slyp_id
  
  class Entity < Grape::Entity
    expose :engaged
    expose :loved
    expose :archived
  end
end