class User < ActiveRecord::Base
  has_many :user_slyps
  has_many :slyps, through: :user_slyps
  has_many :slyp_chat_users
  has_many :slyp_chats, through: :slyp_chat_users

  validates_presence_of :email, :api_token
  validates_uniqueness_of :email

  before_validation :generate_api_token, on: :create
  before_create :generate_access_token

  def generate_api_token
    self.api_token = SecureRandom.hex(10)
  end

  def generate_access_token
    self.access_token = SecureRandom.hex(10)
  end

  def regenerate_access_token
    token = SecureRandom.hex(10)
    self.update_attribute(:access_token, token)
    return token
  end

  def send_slyp(slyp_id, recipient_id)
    slyp_chat_user_ids = self.slyp_chats.where(slyp_id: slyp_id).map{|sc| sc.users }.flatten.map{|u| u.id}
    # don't recreate a slyp_chat between two users
    if !slyp_chat_user_ids.include?(recipient_id)
      slyp_chat = SlypChat.create(slyp_id: slyp_id)
      slyp_chat.slyp_chat_users.create(user_id: self.id)
      slyp_chat.slyp_chat_users.create(user_id: recipient_id)
      UserSlyp.create(user_id: recipient_id, slyp_id: slyp_id)
    else
      # TODO: this could be optimized with SQL
      slyp_chat = self.slyp_chats.where(slyp_id: slyp_id).select {|sc| sc.users.map{|u| u.id }.include?(recipient_id)}.first
    end

    recipient = User.find(recipient_id)
    email = recipient.email
    access_token = recipient.access_token
    sender_email = self.email
    if ENV['RACK_ENV'] != "test" && email.split("@")[1].match("example.com").nil?
      # this should be made into an async job
      mail = Mail.deliver do
        from "Slyp <no-reply@slyp.io>"
        to email
        subject sender_email
        html_part do
          content_type 'text/html; charset=UTF-8'
          body "#{sender_email} has sent you a slyp. <a href='http://api-dev.slyp.io/v1/users/auth?email=#{CGI.escape(email)}&access_token=#{access_token}'>Come on over and check it out!</a>"
        end
      end
    end
    return slyp_chat
  end

  class Entity < Grape::Entity
    expose :id
    expose :email
  end
end