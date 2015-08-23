class UserSlyp < ActiveRecord::Base
  belongs_to :user
  belongs_to :slyp
  enum origin: [:self, :friend]
  validates_uniqueness_of :user_id, scope: :slyp_id
  
  class Entity < Grape::Entity
    expose :engaged
  end
end