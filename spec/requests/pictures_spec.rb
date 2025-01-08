require 'rails_helper'
RSpec.describe 'Pictures', type: :request do
  describe 'DELETE / destroy' do
    context "when access granted" do
      it "deletes selected picture if agent is listing owner" do
        agent = create :user, :agent
        listing = create :listing, :with_pictures, users: [agent]
        picture = listing.pictures.first

        sign_in(agent)
        expect { delete listing_picture_path(listing, picture) }.to change {
          listing.pictures.count
        }.by(-1)
      end

      it "deletes picture if agents from the same brokerage " do
        brokerage = create :brokerage
        agent = create :user, :agent, brokerage: brokerage
        agent2 = create :user, :agent, brokerage: brokerage
        listing = create :listing, :with_pictures, users: [agent]
        picture = listing.pictures.first

        sign_in(agent2)
        expect { delete listing_picture_path(listing, picture) }.to change {
          listing.pictures.count
        }.by(-1)
      end
    end

    context "when access denied" do
      it "redirects to listings page if user admin" do
        admin = create :user, :admin
        listing = create :listing, :with_pictures
        picture = listing.pictures.first

        sign_in(admin)
        delete listing_picture_path(listing, picture)
        expect(response).to redirect_to(root_path)
      end

      it "redirects to listings page if user regular" do
        regular = create :user, :regular
        listing = create :listing, :with_pictures
        picture = listing.pictures.first

        sign_in(regular)
        delete listing_picture_path(listing, picture)
        expect(response).to redirect_to(root_path)
      end

      it "redirects to listings page if agents are from different brokerages" do
        brokerage = create :brokerage
        brokerage2 = create :brokerage
        agent = create :user, :agent, brokerage: brokerage
        agent2 = create :user, :agent, brokerage: brokerage2
        listing = create :listing, :with_pictures, users: [agent]
        picture = listing.pictures.first

        sign_in(agent2)
        delete listing_picture_path(listing, picture)
        expect(response).to redirect_to(root_path)
      end

      it "redirects to listings page if user not logged_in" do
        regular = create :user, :regular
        listing = create :listing, :with_pictures
        picture = listing.pictures.first

        delete listing_picture_path(listing, picture)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end