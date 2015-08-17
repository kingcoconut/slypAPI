require './models/user_slyp.rb'
require './models/user.rb'


class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps
  has_many :slyp_chats

  belongs_to :topic
  enum slyp_type: [:video, :article]
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
    expose :users, using: User::Entity do |slyp, options|
      user = User.find(options[:env]["api.endpoint"].cookies["user_id"].to_i)
      slyp_chats = user.slyp_chats.where(slyp_id: slyp.id)
      users = []
      slyp_chats.each do |slyp_chat| 
        users << slyp_chat.users.where.not(id: user.id).first
      end
      users
    end
    expose :engaged do |slyp, options|
      UserSlyp.where(slyp_id: slyp.id, user_id: options[:env]["api.endpoint"].cookies["user_id"].to_i).first.engaged
    end
    expose :users do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_s
      slyp_id = slyp.id.to_s
      #select distinct U.email  from slyp_chat_users SCU join users U on (SCU.user_id = U.id) where SCU.slyp_chat_id in (select distinct SCU.slyp_chat_id from slyp_chats SC join slyp_chat_users SCU on (SC.id = SCU.slyp_chat_id) where SCU.user_id = 1 and SC.slyp_id = 7) and U.id <> 1;
      # TODO: replace this sql with cleaner activerecord relational mapping utilities
      sql = "select distinct U.email "\
      +"from slyp_chat_users SCU "\
      +"join users U "\
      +"on (SCU.user_id = U.id) "\
      +"where SCU.slyp_chat_id in ("\
        +"select distinct SCU.slyp_chat_id "\
        +"from slyp_chats SC "\
        +"join slyp_chat_users SCU "\
        +"on (SC.id = SCU.slyp_chat_id) "\
        +"where SCU.user_id="+user_id+" and SC.slyp_id="+slyp_id+") "\
      +"and U.id <> "+user_id
      ActiveRecord::Base.connection.select_all(sql)
    end
  end
end










