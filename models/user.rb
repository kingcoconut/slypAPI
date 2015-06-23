class User < ActiveRecord::Base
  attr_accessor :password

  validates_presence_of :email, :api_token
  validates_uniqueness_of :email

  before_save :setup_password
  before_validation :generate_api_token, on: :create

  def setup_password
    return if !self.encrypted_password.nil? || self.password.nil?
    self.salt = SecureRandom.hex(4)
    self.encrypted_password = Digest::SHA1.hexdigest(salt + self.password)
  end

  def valid_password?(password)
    return false if self.encrypted_password.nil?
    return self.encrypted_password == Digest::SHA1.hexdigest(self.salt + password)
  end

  def generate_api_token
    self.api_token = SecureRandom.hex(8)
  end

  class Entity < Grape::Entity
    expose :id
    expose :email
  end
end