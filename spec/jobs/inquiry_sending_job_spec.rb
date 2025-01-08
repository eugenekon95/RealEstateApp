require 'rails_helper'

RSpec.describe InquirySendingJob, type: :job do
  describe '#perform' do
    let(:listing) { create(:listing) }
    let(:inquiry) { create(:inquiry, listing: listing) }

    it 'enqueues ListingMailer jobs' do
      expect do
        InquirySendingJob.new.perform(listing, inquiry)
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(:once)
    end

    describe '.perform_later' do
      it 'adds the job to the queue :default' do
        expect { InquirySendingJob.perform_later }.to have_enqueued_job.on_queue(:default).exactly(:once)
      end
    end
  end
end

