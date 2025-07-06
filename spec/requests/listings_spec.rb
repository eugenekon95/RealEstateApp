# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Listings', type: :request, redis: true do
  describe 'GET /index' do
    it 'returns http success' do
      get listings_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'renders a successful response if user agent' do
      agent = create :user, :agent
      sign_in(agent)
      get new_listing_path
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    let(:brokerage) { create(:brokerage) }
    let(:brokerage2) { create(:brokerage) }
    let(:agent) { create(:user, :agent, brokerage: brokerage) }
    let(:agent2) { create(:user, :agent, brokerage: brokerage) }
    let(:listing) { create(:listing, users: [agent, agent2]) }

    it 'render a successful response' do
      sign_in(agent)
      get edit_listing_url(listing)
      expect(response).to be_successful
    end

    context 'when access granted' do
      context 'when user is from the same brokerage as listing owner' do
        it 'allows to edit listings' do
          sign_in(agent2)
          get edit_listing_url(listing)
          expect(response).to be_successful
        end
      end

      context 'when listing belongs to user' do
        it 'allows to edit listings' do
          sign_in(agent)
          get edit_listing_url(listing)
          expect(response).to be_successful
        end
      end
    end

    context 'when access denied' do
      context 'when  user is from different brokerage as listing owner' do
        let(:brokerage2) { create(:brokerage) }

        it 'doesn`t allow to edit listing' do
          agent3 = create :user, :agent, brokerage: brokerage2
          sign_in(agent3)
          get edit_listing_url(listing)
          expect(response).to redirect_to(listings_path)
        end
      end

      context 'with user admin' do
        it 'doesn`t allow to edit listing' do
          admin = create :user, :admin
          sign_in(admin)
          get edit_listing_url(listing)
          expect(response).to redirect_to(listings_path)
        end
      end

      context 'with user regular' do
        it 'doesn`t allow to edit listing' do
          regular = create :user, :regular
          sign_in(regular)
          get edit_listing_url(listing)
          expect(response).to redirect_to(listings_path)
        end
      end

      context 'when not authorized' do
        it 'doesn`t allow to edit listing' do
          get edit_listing_url(listing)
          expect(response).to redirect_to(listings_path)
        end
      end
    end
  end

  describe 'POST /create' do
    let(:brokerage) { create(:brokerage) }
    let(:agent) { create(:user, :agent, brokerage: brokerage) }

    context 'with valid parameters' do
      it 'creates a new listing' do
        sign_in(agent)
        expect do
          post listings_url, params: {
            listing_form: {
              property_type: 'Flat',
              unit_type: 'sale',
              description: 'Nice place',
              address: 'Some Street 123',
              city: 'Kyiv',
              bedrooms_quantity: 3,
              price: 100000,
              status: 'active',
              user_ids: [agent.id]
            }
          }
        end.to change(Listing, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'doesn`t create new listing' do
        agent = create :user, :agent
        sign_in(agent)
        expect { post listings_url, params: { listing_form: { price: 'price', user_ids: [agent.id] } } }.to change {
          Listing.count
        }.by(0)
      end
    end

    context 'when access denied' do
      context 'with user admin' do
        it ' doesn`t create new listing' do
          admin = create :user, :admin
          sign_in(admin)
          expect { post listings_url, params: { listing_form: attributes_for(:listing) } }.to_not change {
            admin.listings.count
          }.from(0)
          expect(response).to redirect_to(listings_path)
          expect(response).to redirect_to(listings_path)
        end
      end

      context 'with user regular' do
        it ' doesn`t create new listing' do
          regular = create :user, :regular
          sign_in(regular)
          expect { post listings_url, params: { listing_form: attributes_for(:listing) } }.to_not change {
            regular.listings.count
          }.from(0)
        end
      end

      context 'when not authorized user' do
        it ' doesn`t create new listing' do
          expect { post listings_url, params: { listing_form: attributes_for(:listing) } }.to_not change {
            Listing.count
          }.from(0)
          expect(response).to redirect_to(listings_path)
        end
      end
    end
  end

  describe 'PATCH /update' do
    let!(:brokerage) { create(:brokerage) }
    let!(:agent) { create(:user, :agent, brokerage: brokerage) }
    let!(:listing) { create(:listing, price: 8_000, users: [agent]) }

    let!(:brokerage) { create(:brokerage) }
    let!(:agent) { create(:user, :agent, brokerage: brokerage) }
    let!(:listing) { create(:listing, price: 8_000, users: [agent]) }

    context 'with valid parameters' do
      it 'updates the requested listing' do
        sign_in(agent)
        listing = create(:listing, price: 8000, user_ids: [agent.id])

        expect {
          patch listing_path(listing), params: {
            listing_form: {
              property_type: listing.property_type,
              unit_type: listing.unit_type,
              description: listing.description,
              address: listing.address,
              city: listing.city,
              bedrooms_quantity: listing.bedrooms_quantity,
              status: listing.status,
              price: 5000,
              user_ids: [agent.id]
            }
          }
        }.to change { listing.reload.price }.from(8000).to(5000)
      end
    end

    context 'with invalid parameters' do
      it ' doesn`t update the requested listing' do
        sign_in(agent)
        expect { patch listing_path(listing), params: { listing_form: { price: 'price', user_ids: [agent.id] } } }.to_not change {
          listing.reload.price
        }
      end
    end
  end

  describe 'last visited' do
    let!(:listing) { create :listing }
    let(:user) { create :user }

    it 'saves last visited listing to redis' do
      sign_in(user)
      get listing_path(listing)

      expect(REDIS.ZREVRANGE(session[:session_id], 0, 10))
        .to eq ["#{listing.class.name}-#{listing.id}"]
    end
  end
end
