# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { '123456' }

    trait :admin do
      role { :admin }
    end

    trait :agent do
      role { :agent }
      brokerage
    end

    trait :regular do
      role { :regular }
    end
  end
end
