class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps

  enum slyp_type: [:video, :article]

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :url
    expose :raw_url
    expose :author
    expose :date
    expose :text
    expose :description
    expose :top_image
    expose :sitename
    expose :video_url
  end
end