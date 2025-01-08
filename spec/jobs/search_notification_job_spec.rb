require "rails_helper"

RSpec.describe SearchNotificationJob, type: :job, search: true do
  describe '#perform' do
    let(:mailer) { double('mailer') }
    let(:notifier) { double('notifier') }

    describe '#perform' do
      it 'notifies subscribed users' do
        stub_const("#{described_class}::LISTINGS_NUMBER", 1)
        listing3 = create :listing, price: 12000, updated_at: 1.week.ago
        listing1 = create :listing, price: 5000, updated_at: 1.hour.ago
        listing2 = create :listing, price: 10000, updated_at: 2.hour.ago
        listing4 = create :listing, price: 1000, updated_at: 1.hour.ago
        subscribed_user = create :user, :regular
        unsubscribed_user = create :user, :regular
        search = create :search, :empty_search, min_price: 3000, users: []
        saved_search1 = create :saved_search, search: search, user: subscribed_user
        saved_search2 = create :saved_search, search: search, user: unsubscribed_user, subscribed: false
        expect(ListingMailer).to receive(:with).with(
          user: subscribed_user,
          listings: [listing2],
          search: search
        ).and_return(mailer)
        expect(mailer).to receive(:saved_searches_reminder).and_return(notifier)
        expect(notifier).to receive(:deliver_later).once
        Listing.search_index.refresh
        perform_enqueued_jobs { described_class.perform_later }
      end
    end
  end
end

