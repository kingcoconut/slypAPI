FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}+#{Faker::Internet.email}" }
    name {
      # User first + last name here so that we don't get into issues with user.name being differnt than
      # preson.full_name (which doesn't include prefix)
      [Faker::Name.first_name, Faker::Name.last_name].join(' ')
    }

    trait :with_slyps do
      after(:create) do |user|
        10.times do
          slyp = FactoryGirl.create(:slyp)
          UserSlyp.create(user_id: user.id, slyp_id: slyp.id)
        end
      end
    end

    trait :with_slyps_and_chats do
      after(:create) do |user|
        10.times do
          slyp = FactoryGirl.create(:slyp)
          UserSlyp.create(user_id: user.id, slyp_id: slyp.id)
          slyp_chat = user.slyp_chats.create(slyp_id: slyp.id)
          slyp_chat.slyp_chat_messages.create(user_id: user.id, content: Faker::Lorem.sentence)
        end
      end
    end
  end
end