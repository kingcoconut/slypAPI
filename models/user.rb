class User < ActiveRecord::Base
  has_many :user_slyps
  has_many :slyps, through: :user_slyps
  has_many :slyp_chat_users
  has_many :slyp_chats, through: :slyp_chat_users

  validates_presence_of :email, :api_token
  validates_uniqueness_of :email

  before_validation :generate_api_token, on: :create
  before_create :generate_access_token, :generate_icon

  @@api_domain = YAML::load(File.open('config/domains.yml'))[ENV['RACK_ENV']]["api"]

  def generate_api_token
    self.api_token = SecureRandom.hex(10)
  end

  def generate_access_token
    self.access_token = SecureRandom.hex(10)
  end

  def generate_icon
    self.icon_url = IconService.generate_random
  end

  def regenerate_access_token
    token = SecureRandom.hex(10)
    self.update_attribute(:access_token, token)
    return token
  end

  def send_slyp(slyp_id, recipient_id, sender_id, origin)
    slyp_chat_user_ids = self.slyp_chats.where(slyp_id: slyp_id).map{|sc| sc.users }.flatten.map{|u| u.id}
    # don't recreate a slyp_chat between two users
    if !slyp_chat_user_ids.include?(recipient_id)
      slyp_chat = SlypChat.create(slyp_id: slyp_id)
      slyp_chat.slyp_chat_users.create(user_id: self.id)
      slyp_chat.slyp_chat_users.create(user_id: recipient_id)
      UserSlyp.create(user_id: recipient_id, slyp_id: slyp_id, sender_id: sender_id, origin: origin)
    else
      # TODO: this could be optimized with SQL
      slyp_chat = self.slyp_chats.where(slyp_id: slyp_id).select {|sc| sc.users.map{|u| u.id }.include?(recipient_id)}.first
    end

    recipient = User.find(recipient_id)

    if ENV['RACK_ENV'] != "test" && email.split("@")[1].match("example.com").nil?
      # this should be made into an async job
      SendSlypWorker.perform_async(self.email, recipient.email, recipient.access_token, @@api_domain)
    end
    return slyp_chat
  end

  class Entity < Grape::Entity
    expose :id
    expose :email
    expose :icon_url
  end
end