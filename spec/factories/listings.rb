# frozen_string_literal: true
FactoryBot.define do
  factory :listing do
    property_type { 'House' }
    address { Faker::Address.full_address }
    price { Faker::Number.between(from: 250_000, to: 25_000_000) }
    description { 'lorem' }
    status { :active }
    bedrooms_quantity { Faker::Number.between(from: 1, to: 8) }
    city { Faker::Address.city }
    users { [association(:user)] }

    trait :with_pictures do
      after :build do |listing|
        listing.pictures.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test_picture.jpeg')),
          filename: 'test_picture.jpeg',
          content_type: 'image/jpeg')
      end
    end
  end
end
