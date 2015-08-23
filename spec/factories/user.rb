FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}+#{Faker::Internet.email}" }
    name { Faker::Name.name }
    sign_in_count { 1 }

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
          to_user = FactoryGirl.create(:user)

          UserSlyp.create(user_id: user.id, slyp_id: slyp.id, sender_id: user.id)
          slyp_chat = user.slyp_chats.create(slyp_id: slyp.id)
          slyp_chat.slyp_chat_messages.create(user_id: user.id, content: Faker::Lorem.sentence)
          SlypChatUser.create(user_id: to_user.id, slyp_chat_id: slyp_chat.id)
        end
      end
    end
  end
end