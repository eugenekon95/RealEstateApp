require 'rails_helper'

RSpec.describe UpdateFavoriteNotificationsJob, type: :job do
  describe '#perform' do
    let(:listing) { create(:listing) }
    let(:user) { create(:user) }
    let!(:favorite) { create(:favorite, listing: listing, user: user) }

    it 'enqueues ListingMailer jobs' do
      expect do
        UpdateFavoriteNotificationsJob.new.perform(listing)
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(:once)
    end

    it 'enqueues ListingMailer job with subscription' do
      create(:mailer_subscription, user: user, mailer: 'ListingMailer', subscribed: true)

      expect do
        UpdateFavoriteNotificationsJob.new.perform(listing)
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(:once)
    end

    it 'does not enqueue mailer job for unsubscribed user' do
      create(:mailer_subscription, user: user, mailer: 'ListingMailer', subscribed: false)

      expect do
        UpdateFavoriteNotificationsJob.new.perform(listing)
      end.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it 'does not enqueue mailer job for unsubscribed user for certain mailer' do
      build(:mailer_subscription, user: user, mailer: 'TestMailer', subscribed: true).save(validate: false)

      expect do
        UpdateFavoriteNotificationsJob.new.perform(listing)
      end.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  describe '.perform_later' do
    it 'adds the job to the queue :default' do
      expect { UpdateFavoriteNotificationsJob.perform_later }.to have_enqueued_job.on_queue(:default).exactly(:once)
    end
  end
end
