require 'rails_helper'

RSpec.describe 'Inquiries', type: :request do
  describe 'GET /inquiries' do
    it 'returns http success if logged in as agent' do
      agent = create :user, :agent
      sign_in(agent)
      get inquiries_path
      expect(response).to have_http_status(:success)
    end

    it 'redirects to listings page if not logged in' do
      get inquiries_path
      expect(response).to redirect_to root_path
    end

    it 'redirects to listings page if logged in as regular' do
      regular = create :user
      sign_in(regular)
      get inquiries_path
      expect(response).to redirect_to root_path
    end

    it 'redirects to listings page if logged in as admin' do
      admin = create :user, :admin
      sign_in(admin)
      get inquiries_path
      expect(response).to redirect_to root_path
    end
  end

  describe 'POST #create' do
    let!(:agent) { create(:user, :agent) }
    let!(:listing) { create(:listing) }

    it 'redirects to listing show page' do
      post listing_inquiries_path(listing), params:
        {
          inquiry: attributes_for(:inquiry, listing: listing)
        }
      expect(response).to redirect_to listing_url(listing)
    end

    it 'creates new Inquiry' do
      expect do
        post listing_inquiries_path(listing), params:
          {
            inquiry: attributes_for(:inquiry, listing: listing)
          }
      end.to change(Inquiry, :count).by(1)
    end

    it 'sets recievers to inquiry' do
      post listing_inquiries_path(listing, Inquiry), params: { inquiry: attributes_for(:inquiry, listing: listing) }

      expect(assigns(:inquiry).recievers).to match_array listing.users.pluck(:email)
    end
  end
end

