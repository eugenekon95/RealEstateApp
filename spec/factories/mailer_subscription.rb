FactoryBot.define do
  factory :mailer_subscription do
    user
    subscribed { true }
    mailer { 'ListingMailer' }
  end
end
