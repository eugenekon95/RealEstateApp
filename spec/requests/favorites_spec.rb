# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Favorites', type: :request do
  describe 'GET /index' do
    context 'when user regular' do
      it 'returns http success' do
        regular = create :user, :regular
        sign_in(regular)

        get favorites_path
        expect(response).to be_successful
      end
    end

    context 'when user admin' do
      it 'returns http redirect' do
        admin = create :user, :admin
        sign_in(admin)
        get favorites_path

        expect(response).to be_successful
      end
    end

    context 'when user agent' do
      it 'returns http success' do
        agent = create :user, :agent
        sign_in(agent)
        get favorites_path

        expect(response).to be_successful
      end
    end

    context 'when not authorized user' do
      it 'returns http redirect' do
        get favorites_path

        expect(response).to redirect_to(listings_path)
      end
    end
  end

  describe 'POST /create' do
    context 'when user regular' do
      it 'creates a new favorite' do
        regular = create :user, :regular
        listing = create :listing
        sign_in(regular)

        expect { post favorites_url, params: { listing_id: listing.id } }.to change {
          regular.favorites.count
        }.by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user agent' do
      it 'creates a new favorite' do
        agent = create :user, :agent
        listing = create :listing
        sign_in(agent)

        expect { post favorites_url, params: { listing_id: listing.id } }.to change {
          agent.favorites.count
        }.by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user admin' do
      it 'creates a new favorite' do
        admin = create :user, :admin
        listing = create :listing
        sign_in(admin)

        expect { post favorites_url, params: { listing_id: listing.id } }.to change {
          admin.favorites.count
        }.by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when not authorized user' do
      it 'doesn`t create a new favorite' do
        listing = create :listing

        post favorites_path(listing_id: listing.id, format: :turbo_stream)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:listing) { create :listing }
    context 'when user regular' do
      it 'deletes  favorite' do
        regular = create :user, :regular
        favorite = create :favorite, user: regular, listing: listing
        sign_in(regular)

        expect { delete favorite_path(listing) }.to change(Favorite, :count).by(-1)
      end
    end

    context 'when user admin' do
      it 'deletes  favorite' do
        admin = create :user, :admin
        favorite = create :favorite, user: admin, listing: listing
        sign_in(admin)

        expect { delete favorite_path(listing) }.to change(Favorite, :count).by(-1)
      end
    end

    context 'when user agent' do
      it 'deletes  favorite' do
        agent = create :user, :agent
        favorite = create :favorite, user: agent, listing: listing
        sign_in(agent)

        expect { delete favorite_path(listing) }.to change(Favorite, :count).by(-1)
      end
    end

    context 'when not authorized user' do
      it ' doesn`t delete  favorite' do
        admin = create :user, :admin
        favorite = create :favorite, user: admin

        delete favorite_path(favorite)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user authorized' do
      it "does not delete other user's favorite" do
        listing = create :listing
        regular = create :user, :regular
        regular2 = create :user, :regular
        favorite = create :favorite, user: regular, listing: listing
        sign_in(regular2)

        expect { delete favorite_path(favorite), xhr: true }.to change(Favorite, :count).by(0)
      end
    end
  end
end
