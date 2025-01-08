FactoryBot.define do
  factory :inquiry do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    message { Faker::Lorem.sentence }
    association :listing
    recievers { listing.users.pluck(:email) }
  end
end
