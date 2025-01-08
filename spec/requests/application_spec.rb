require 'rails_helper'
RSpec.describe 'Application', type: :request, redis: true do
  describe 'five last visited listings' do
    context 'when user logged_in' do
      let!(:listing1) { create :listing }
      let!(:listing2) { create :listing }
      let!(:listing3) { create :listing }
      let!(:listing4) { create :listing }
      let!(:listing5) { create :listing }
      let!(:listing6) { create :listing }
      let(:user) { create :user }

      it 'saves 5 last visited listings to redis' do
        sign_in(user)
        get listing_path(listing1)
        get listing_path(listing2)
        get listing_path(listing3)
        get listing_path(listing4)
        get listing_path(listing5)
        get listing_path(listing6)

        expect(REDIS.ZREVRANGE(session[:session_id], 0, 5))
          .to eq ["#{listing6.class.name}-#{listing6.id}",
                  "#{listing5.class.name}-#{listing5.id}",
                  "#{listing4.class.name}-#{listing4.id}",
                  "#{listing3.class.name}-#{listing3.id}",
                  "#{listing2.class.name}-#{listing2.id}"]
      end
    end
  end
end

