# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Brokerages', type: :request do
  describe 'GET /index' do
    it 'returns http success if user admin' do
      admin = create :user, :admin
      sign_in(admin)
      get admin_brokerages_path
      expect(response).to have_http_status(:success)
    end

    it 'returns http redirect if user agent' do
      agent = create :user, :agent
      sign_in(agent)
      get admin_brokerages_path
      expect(response).to have_http_status(:redirect)
    end

    it 'returns http redirect if user regular' do
      regular = create :user
      sign_in(regular)
      get admin_brokerages_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /new' do
    it 'renders a successful response if user admin' do
      admin = create :user, :admin
      sign_in(admin)
      get new_admin_brokerage_path
      expect(response).to be_successful
    end

    it 'returns http redirect if user agent' do
      agent = create :user, :agent
      sign_in(agent)
      get new_admin_brokerage_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters & user admin' do
      it 'creates a new brokerage' do
        admin = create :user, :admin
        sign_in(admin)
        expect { post admin_brokerages_url, params: { brokerage: attributes_for(:brokerage) } }.to change {
                                                                                                     Brokerage.count
                                                                                                   }.from(0).to(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters & user regular' do
      it ' doesn`t create new brokerage' do
        user = create :user
        sign_in(user)
        expect { post admin_brokerages_url, params: { brokerage: { city: nil } } }.to_not change {
                                                                                            Brokerage.count
                                                                                          }.from(0)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
