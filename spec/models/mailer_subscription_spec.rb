require 'rails_helper'
RSpec.describe MailerSubscription, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    let(:mailer_subscription) { build(:mailer_subscription) }

    it 'is valid with valid params' do
      expect(mailer_subscription).to be_valid
    end

    it 'is not valid with subscribed nil' do
      mailer_subscription.subscribed = nil

      expect(mailer_subscription).to be_invalid
      expect(mailer_subscription.errors.messages_for(:subscribed)).to eq(['must be a true or false value'])
    end
    
    it 'is not valid if not unique for user' do
      user = create :user
      create :mailer_subscription, user: user, mailer: 'ListingMailer'
      new_subscription = build :mailer_subscription, user: user, mailer: 'ListingMailer'

      expect(new_subscription).to be_invalid
    end
  end
end
