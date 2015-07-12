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
  end
end