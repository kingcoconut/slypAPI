class User < ActiveRecord::Base
  has_many :user_slyps
  has_many :slyps, through: :user_slyps

  validates_presence_of :email, :api_token
  validates_uniqueness_of :email

  before_validation :generate_api_token, on: :create

  def generate_api_token
    self.api_token = SecureRandom.hex(8)
  end

  def generate_access_token
    token = SecureRandom.hex(10)
    self.update_attribute(:access_token, token)
    return token
  end

  class Entity < Grape::Entity
    expose :id
    expose :email
  end
end