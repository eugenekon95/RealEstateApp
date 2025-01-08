require 'rails_helper'

RSpec.describe 'MailerSubscriptions', type: :request do
  describe 'GET /edit' do
    it 'returns http success' do
      user = create :user
      sign_in(user)
      get edit_mailer_subscription_url(user, mailer: 'ListingMailer')

      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    it 'updates subscription to mailer' do
      user = create :user
      sign_in(user)
      mailer_subscription = create :mailer_subscription, user: user
      patch mailer_subscription_url(user), params: { mailer: mailer_subscription.mailer, subscribed: false }

      expect(mailer_subscription.reload.subscribed).to eq false
    end
  end
end
