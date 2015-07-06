class User < ActiveRecord::Base
  attr_accessor :password

  validates_presence_of :email, :api_token
  validates_uniqueness_of :email

  before_validation :generate_api_token, on: :create

  def generate_api_token
    self.api_token = SecureRandom.hex(8)
  end

  class Entity < Grape::Entity
    expose :id
    expose :email
  end
end