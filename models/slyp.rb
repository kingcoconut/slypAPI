require './models/user_slyp.rb'
require './models/user.rb'


class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps
  has_many :slyp_chats

  belongs_to :topic
  enum slyp_type: [:video, :article]

  def get_friends(user_id)
    sql = "select u.id, u.email, count(distinct scm.id) as unread_messages "\
          +"from ( "\
          +  "select scu.slyp_chat_id, scu.last_read_at "\
          +    "from slyp_chats sc "\
          +  "join slyp_chat_users scu "\
          +  "on (sc.id = scu.slyp_chat_id) "\
          +  "where scu.user_id = "+user_id+" and sc.slyp_id="+self.id.to_s+" "\
          +") x "\
          +"join slyp_chat_users scu "\
          +"on (scu.slyp_chat_id = x.slyp_chat_id and scu.user_id <> "+user_id+") "\
          +"join users u "\
          +"on (scu.user_id = u.id) "\
          +"left join slyp_chat_messages scm "\
          +"on (scm.user_id = u.id and scm.slyp_chat_id = x.slyp_chat_id) "\
          +"group by u.id, u.email; "
    return ActiveRecord::Base.connection.select_all(sql)
  end

  def get_unread_messages_count(user_id)
    sql = "select count(scm.id) "\
          +"from slyp_chats sc "\
          +"join slyp_chat_users scu "\
          +"on (sc.id = scu.slyp_chat_id) "\
          +"join slyp_chat_messages scm "\
          +"on (scm.slyp_chat_id = sc.id) "\
          +"where scu.user_id = "+user_id+" and sc.slyp_id = "+self.id.to_s+" and scm.user_id <> "+user_id+" and scm.created_at > scu.last_read_at; "
    return ActiveRecord::Base.connection.select_all(sql)
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :url
    expose :raw_url
    expose :author
    expose :date
    expose :text
    expose :summary
    expose :description
    expose :top_image
    expose :site_name
    expose :video_url
    expose :created_at
    expose :topic
    expose :engaged do |slyp, options|
      UserSlyp.where(slyp_id: slyp.id, user_id: options[:env]["api.endpoint"].cookies["user_id"].to_i).first.engaged
    end
    expose :users do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_s
      slyp.get_friends(user_id)
    end
    expose :unread_messages do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_s
      slyp.get_unread_messages_count(user_id)
    end
  end
end










