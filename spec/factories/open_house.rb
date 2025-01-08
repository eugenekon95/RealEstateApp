FactoryBot.define do
  factory :open_house do
    date { Faker::Date.forward(days: 14) }
    start_time { '09:00' }
    end_time { '18:00' }
    listing
  end
end
