require "rails_helper"

RSpec.describe ListingMailer, type: :mailer do
  describe 'update_favorite_listing_mailer' do
    let(:user) { create(:user) }
    let(:listing) { create(:listing) }

    context 'when deliver now' do
      let(:mail) { ListingMailer.with(user: user, listing: listing).update_favorite_listing.deliver_now }

      it 'renders the headers' do
        expect(mail.subject).to eq('Your Favorite Listing Was Updated')
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(['estateryapp@gmail.com'])
      end

      it 'includes correct info' do
        expect(mail.body.encoded).to include(user.email)
        expect(mail.body.encoded).to include(listing.property_type)
        expect(mail.body.encoded).to include(listing.address)
        expect(mail.body.encoded).to include(listing.price.to_s)
        expect(mail.body.encoded).to include('Unsubscribe')

      end

      it 'sends notification about favorite update' do
        expect { mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when deliver later' do
      let(:mail) { ListingMailer.with(user: user, listing: listing).update_favorite_listing.deliver_later }

      it 'enqueues mail delivery job' do
        expect { mail }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(:once)
      end
    end
  end
end
