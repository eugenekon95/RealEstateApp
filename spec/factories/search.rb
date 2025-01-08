FactoryBot.define do
  factory :search do
    min_price { Faker::Number.between(from: 250_000, to: 25_000_000) }
    max_price { Faker::Number.between(from: 1_000_000, to: 25_000_000) }
    min_bedrooms { Faker::Number.between(from: 1, to: 8) }
    city { Faker::Address.city }
    brokerage_id { [association(:brokerage)] }
    order { 'Newest' }
    users { [association(:user)] }

    trait :empty_search do
      city { nil }
      min_bedrooms { nil }
      min_price { nil }
      max_price { nil }
      brokerage_id { nil }
      open_house { nil }
      users { [association(:user)] }
    end
  end
end

