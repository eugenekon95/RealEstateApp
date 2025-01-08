# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenHouses', type: :request do
  describe 'GET #new' do
    let(:brokerage) { create :brokerage }
    let(:agent) { create :agent, brokerage: brokerage }

    context 'when access granted' do
      context 'agent is listing owner' do
        let(:agent) { create :user, :agent, brokerage: brokerage }

        it 'returns http success' do
          sign_in(agent)
          listing = create :listing, users: [agent]
          get new_listing_open_house_path(listing)
          expect(response).to be_successful
        end
      end

      context 'agent & listing owner have the same brokerage' do
        let(:agent) { create :user, :agent, brokerage: brokerage }
        let(:agent2) { create :user, :agent, brokerage: brokerage }
        let(:listing) { create :listing, users: [agent] }

        it 'returns http success' do
          sign_in(agent2)
          get new_listing_open_house_path(listing)
          expect(response).to be_successful
        end
      end
    end

    context 'when access denied' do
      context 'when user admin' do
        let(:agent) { create :user, :agent }
        let(:admin) { create :user, :admin }
        let(:listing) { create :listing, users: [agent] }

        it 'redirects to listings page' do
          sign_in(admin)
          expect(get(new_listing_open_house_path(listing))).to redirect_to listings_path
          expect(flash[:alert]).to match('Not authorized to manage openhouses.')
        end
      end

      context 'when user regular' do
        let(:agent) { create :user, :agent }
        let(:regular) { create :user, :regular }
        let(:listing) { create :listing, users: [agent] }

        it 'redirects to listings page' do
          sign_in(regular)
          expect(get(new_listing_open_house_path(listing))).to redirect_to listings_path
          expect(flash[:alert]).to match('Not authorized to manage openhouses.')
        end
      end

      context 'when not authorized user' do
        let(:agent) { create :user, :agent }
        let(:listing) { create :listing, users: [agent] }

        it 'redirects to listings page' do
          expect(get(new_listing_open_house_path(listing))).to redirect_to listings_path
          expect(flash[:alert]).to match('Not authorized to manage openhouses.')
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:brokerage) { create :brokerage }
    let(:brokerage2) { create :brokerage }

    context 'when access granted' do
      context 'agent is listing owner' do
        let(:agent) { create :user, :agent, brokerage: brokerage }

        it 'allow to edit openhouse' do
          sign_in(agent)
          listing = create :listing, users: [agent]
          open_house = create :open_house, listing: listing

          get edit_listing_open_house_path(listing, open_house)
          expect(response).to be_successful
        end
      end

      context 'agent & listing owner have the same brokerage' do
        let(:agent) { create :user, :agent, brokerage: brokerage }
        let(:agent2) { create :user, :agent, brokerage: brokerage }
        let(:listing) { create :listing, users: [agent] }

        it 'allow to edit openhouse' do
          sign_in(agent2)
          open_house = create :open_house, listing: listing

          get edit_listing_open_house_path(listing, open_house)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'when access denied' do
      context 'when  user is from different brokerage as listing owner' do
        let(:agent) { create :user, :agent, brokerage: brokerage }
        let(:agent2) { create :user, :agent, brokerage: brokerage2 }
        let(:listing) { create :listing, users: [agent] }

        it 'redirects to listings page' do
          open_house = create :open_house, listing: listing
          sign_in(agent2)
          get edit_listing_url(listing, open_house)
          expect(response).to redirect_to(listings_path)
        end
      end

      context 'when user is admin' do
        let(:admin) { create :user, :admin }
        let(:agent) { create :user, :agent }
        let(:listing) { create :listing, users: [agent] }
        let(:open_house) { create :open_house, listing: listing }

        it 'redirects to listings page' do
          sign_in(admin)
          get edit_listing_open_house_path(listing, open_house)
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'when user is regular' do
        let(:regular) { create :user, :regular }
        let(:agent) { create :user, :agent }
        let(:listing) { create :listing, users: [agent] }
        let(:open_house) { create :open_house, listing: listing }

        it 'redirects to listings page' do
          sign_in(regular)
          get edit_listing_open_house_path(listing, open_house)
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'when not authorized user' do
        let(:agent) { create :user, :agent }
        let(:listing) { create :listing, users: [agent] }
        let(:open_house) { create :open_house, listing: listing }

        it 'redirects to listings page' do
          get edit_listing_open_house_path(listing, open_house)
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end

  describe 'POST #create' do
    let(:brokerage) { create :brokerage }

    context 'when authorized user is agent' do
      let(:agent) { create :user, :agent }
      let(:listing) { create :listing, users: [agent] }

      context 'agent is listing owner' do
        let!(:listing) { create :listing, users: [agent] }

        it 'creates new openhouse' do
          sign_in(agent)
          expect do
            post listing_open_houses_path(listing),
                 params: { open_house: attributes_for(:open_house, listing_id: listing.id) }
          end.to change {
                   listing.open_houses.count
                 }.from(0).to(1)
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'agent & listing owner have the same brokerage' do
        let(:agent) { create :user, :agent, brokerage: brokerage }
        let(:agent2) { create :user, :agent, brokerage: brokerage }
        let(:listing) { create :listing, users: [agent] }

        it 'creates new openhouse' do
          sign_in(agent2)
          expect do
            post listing_open_houses_path(listing),
                 params: { open_house: attributes_for(:open_house, listing_id: listing.id) }
          end.to change {
                   listing.open_houses.count
                 }.from(0).to(1)

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to listings_path
        end
      end
    end

    context 'authorized user is admin' do
      let(:admin) { create :user, :admin }
      let(:agent) { create :user, :agent, brokerage: brokerage }
      let(:listing) { create :listing, users: [agent] }

      it 'doesn`t create new openhouse' do
        sign_in(admin)
        expect do
          post listing_open_houses_path(listing),
               params: { open_house: attributes_for(:open_house, listing_id: listing.id) }
        end.to_not change {
                     listing.open_houses.count
                   }.from(0)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to listings_path
      end
    end

    context 'authorized user is regular' do
      let(:regular) { create :user, :admin }
      let(:agent) { create :user, :agent, brokerage: brokerage }
      let(:listing) { create :listing, users: [agent] }

      it 'doesn`t create new openhouse' do
        sign_in(regular)
        expect do
          post listing_open_houses_path(listing),
               params: { open_house: attributes_for(:open_house, listing_id: listing.id) }
        end.to_not change {
                     listing.open_houses.count
                   }.from(0)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to listings_path
      end
    end
  end

  describe 'PATCH #update' do
    let(:brokerage) { create :brokerage }
    let(:agent) { create :agent, brokerage: brokerage }
    let(:listing) { create :listing, users: [agent] }

    context 'when authorized user is agent' do
      context 'agent is listing owner' do
        let(:agent) { create :user, :agent, brokerage: brokerage }

        it 'updates open house' do
          sign_in(agent)
          open_house = create :open_house, date: Date.current + 2.days, listing: listing
          patch listing_open_house_path(listing, open_house), params: { open_house: { date: Date.current + 5.days } }
          expect(open_house.reload.date).to eq Date.current + 5.days
        end
      end

      context 'agent & listing owner have the same brokerage' do
        let(:agent) { create :user, :agent, brokerage: brokerage }
        let(:agent2) { create :user, :agent, brokerage: brokerage }
        let(:listing) { create :listing, users: [agent] }

        it 'updates requested openhouse' do
          sign_in(agent2)
          open_house = create :open_house, listing: listing
          patch listing_open_house_path(listing, open_house), params: { open_house: { date: Date.current + 5.days } }
          expect(open_house.reload.date).to eq Date.current + 5.days
        end
      end
    end

    context 'when not authorized user' do
      let(:agent) { create :user, :agent }
      let(:listing) { create :listing, users: [agent] }
      let(:open_house) { create :open_house, date: Date.current + 2.days, listing: listing }

      it 'redirects to listings page' do
        patch listing_open_house_path(listing, open_house), params: { open_house: { date: Date.current + 5.days } }

        expect(open_house.reload.date).to eq Date.current + 2.days

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:brokerage) { create :brokerage }

    context 'when authorized user is agent' do
      let(:agent) { create :user, :agent }
      let(:listing) { create :listing, users: [agent] }

      context 'agent is listing owner' do
        it 'deletes  openhouse' do
          sign_in(agent)
          open_house = create :open_house, date: Date.current + 2.days, listing: listing
          expect do
            delete listing_open_house_path(listing, open_house)
          end.to change {
            listing.open_houses.count
          }.by(-1)
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'agent & listing owner have the same brokerage' do
        let(:agent) { create :user, :agent, brokerage: brokerage }
        let(:agent2) { create :user, :agent, brokerage: brokerage }
        let(:listing) { create :listing, users: [agent] }

        it 'deletes  openhouse' do
          sign_in(agent2)
          open_house = create :open_house, date: Date.current + 2.days, listing: listing
          expect do
            delete listing_open_house_path(listing, open_house)
          end.to change {
                   listing.open_houses.count
                 }.from(1).to(0)
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'authorized user is admin' do
      let(:admin) { create :user, :admin }
      let(:agent) { create :user, :agent, brokerage: brokerage }
      let(:listing) { create :listing, users: [agent] }
      let(:open_house) { create :open_house, date: Date.current + 2.days, listing: listing }

      it 'doesn`t delete openhouse' do
        sign_in(admin)
        delete listing_open_house_path(listing, open_house)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'authorized user is regular' do
      let(:regular) { create :user, :admin }
      let(:agent) { create :user, :agent, brokerage: brokerage }
      let(:listing) { create :listing, users: [agent] }
      let(:open_house) { create :open_house, date: Date.current + 2.days, listing: listing }

      it 'doesn`t delete openhouse' do
        sign_in(agent)
        expect do
          delete listing_open_house_path(listing, open_house)
        end.to_not change {
                     listing.open_houses.count
                   }.from(0)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
