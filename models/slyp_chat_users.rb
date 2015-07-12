class SlypChatUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :slyp_chat
end