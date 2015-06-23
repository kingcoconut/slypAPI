FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}+#{Faker::Internet.email}" }
    name {
      # User first + last name here so that we don't get into issues with user.name being differnt than
      # preson.full_name (which doesn't include prefix)
      [Faker::Name.first_name, Faker::Name.last_name].join(' ')
    }
  end
end