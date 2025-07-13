# frozen_string_literal: true

# Відключаємо Searchkick колбеки, щоб не намагатися індексувати записи без підключення до ES
Searchkick.disable_callbacks

Listing.destroy_all
User.destroy_all
Brokerage.destroy_all

User.create(email: 'admin@estatery.com', password: '12345678', role: :admin)

3.times do
  Brokerage.create!(
    name: Faker::Company.name,
    address: Faker::Address.street_address,
    city: Faker::Address.city
  )
end

10.times do
  User.create!(
    email: Faker::Internet.email,
    password: '12345678',
    role: :agent,
    brokerage_id: Brokerage.all.ids.sample
  )
end

10.times do
  User.create!(
    email: Faker::Internet.email,
    password: '12345678',
    role: %w[regular admin].sample
  )
end

10.times do
  User.create!(
    email: Faker::Internet.email,
    password: '12345678',
    role: :agent,
    brokerage_id: Brokerage.all.ids.sample
  )
end

10.times do
  Listing.create!(
    property_type: %w[House Flat Studio].sample,
    address: Faker::Address.street_address,
    price: Faker::Number.between(from: 5_000, to: 12_000),
    status: %i[active inactive].sample,
    description: 'lorem',
    city: Faker::Address.city,
    bedrooms_quantity: Faker::Number.between(from: 0, to: 10),
    user_ids: [User.where(role: :agent).ids.sample]
  )
end

User.create(email: 'agent@estatery.com', password: '12345678', role: :agent, brokerage_id: Brokerage.all.ids.sample)

# Вмикаємо колбеки Searchkick назад
Searchkick.enable_callbacks
Listing.reindex