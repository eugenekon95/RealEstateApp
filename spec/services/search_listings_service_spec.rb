# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchListingsService, search: true do
  def filtered_params(params = {})
    FilterParamsService.new(params).call
  end

  context 'order' do
    it 'returns Newest first' do
      older = create(:listing, created_at: 5.days.ago)
      newer = create(:listing, created_at: 2.days.ago)

      params = filtered_params(order: 'Newest')
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq([newer, older])
    end

    it 'returns Recently updated first' do
      recently_updated = create(:listing, updated_at: 5.days.ago)
      sale = create(:listing, updated_at: 2.month.ago)

      params = filtered_params(order: 'Recently updated')
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq([recently_updated, sale])
    end

    it 'returns Low Price First' do
      more_expensive = create(:listing, price: 3_000)
      less_expensive = create(:listing, price: 2_000)

      params = filtered_params(order: 'Low Price First')
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq([less_expensive, more_expensive])
    end

    it 'returns High Price first' do
      more_expensive = create(:listing, price: 3_000)
      less_expensive = create(:listing, price: 2_000)

      params = filtered_params(order: 'High Price First')
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq([more_expensive, less_expensive])
    end

    it 'returns Newest first by default' do
      older = create(:listing, created_at: 5.days.ago)
      newer = create(:listing, created_at: 2.days.ago)

      params = filtered_params # no `order` param
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq([newer, older])
    end

    it 'returns Alphabetical' do
      house = create(:listing, property_type: 'House')
      flat = create(:listing, property_type: 'Flat')

      params = filtered_params(order: 'Alphabetical')
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq([flat, house])
    end
  end

  context 'without params' do
    it 'returns all the listings' do
      params = filtered_params
      create_list :listing, 5
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call
      expect(result.length).to eq 5
    end
  end

  context 'filter by price' do
    let!(:high_price_listing) { create :listing, price: 5_000 }
    let!(:mid_price_listing) { create :listing, price: 4_000 }
    let!(:low_price_listing) { create :listing, price: 3_000 }

    it 'returns listings above or equal price' do
      params = filtered_params(min_price: 4_000)
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to match_array([high_price_listing, mid_price_listing])
    end

    it 'returns listings below or equal price' do
      params = filtered_params(max_price: 4_000)
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result).to match_array([low_price_listing, mid_price_listing])
    end

    it 'returns listings with exact Price' do
      params = filtered_params(min_price: 3_000, max_price: 3_000)
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result).to match_array [low_price_listing]
    end
  end

  context 'filter by bedrooms' do
    let!(:studio) { create :listing, bedrooms_quantity: 0 }
    let!(:two_beds) { create :listing, bedrooms_quantity: 2 }
    let!(:four_beds) { create :listing, bedrooms_quantity: 4 }

    it 'returns 2 of 3 listings when bedrooms = 2' do
      params = filtered_params(min_bedrooms: 2)
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq [four_beds, two_beds]
    end

    it 'returns no listing when bedrooms = 5' do
      params = filtered_params(min_bedrooms: 5)
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call

      expect(result).to match_array []
    end
  end

  context 'filter by brokerage' do
    let(:brokerage) { create :brokerage }
    let(:agent) { create :user, :agent, brokerage: brokerage }
    let!(:listing) { create :listing, users: [agent] }
    let(:other_brokerage) { create :brokerage }
    let(:other_agent) { create :user, :agent, brokerage: other_brokerage }
    let!(:other_listing) { create :listing, users: [other_agent] }

    it 'returns listing that belong to certain brokerage' do
      params = filtered_params(brokerage_id: brokerage.id)
      Listing.search_index.refresh
      result = SearchListingsService.new(params).call
      expect(result.to_a).to match_array [listing]
    end
  end

  context 'filter by open houses' do
    let(:listing) { create :listing }
    let!(:open_house) { create :open_house, listing: listing }
    let!(:other_listing) { create :listing }

    it 'returns listing with upcoming open_house' do
      params = filtered_params(closest_open_house: 'on')
      Listing.reindex
      result = SearchListingsService.new(params).call

      expect(result.to_a).to eq [listing]
    end
  end
end
