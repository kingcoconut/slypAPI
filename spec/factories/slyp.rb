FactoryGirl.define do #TODO: create and assign topic_id
  factory :slyp do
    sequence(:title) { |n| "Title-#{n}" }
    url { "https://google.com/#{SecureRandom.hex(8)}" }
    raw_url { "https://google.com/#{SecureRandom.hex(8)}?foo=bar" }
    author { Faker::Name.name }
    date { Time.now - rand(1000).days }
    text { Faker::Lorem.paragraphs(rand(100)+1).join(" ") }
    description { Faker::Lorem.paragraphs(rand(4)+1).join(" ") }
    sequence(:top_image) { |n| "http://www.crazyimages.com/image-#{n}.png" }
    sequence(:video_url) { |n| "http://www.crazyvideos.com/image-#{n}.mp4" }
    site_name { "www." + Faker::App.name + ".com" }
  end
end
