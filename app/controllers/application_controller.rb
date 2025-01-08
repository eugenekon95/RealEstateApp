# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :last_visited

  private

  def last_visited
    records = REDIS.ZREVRANGE(session[:session_id], 0, 5)
    listing_ids = records.map { |r| r.split('-').last }
    listings = Listing.where(id: listing_ids)
    sorted_listings = listings.sort_by { |listing| records.index("#{listing.class.name}-#{listing.id}") }
    @last_visited = sorted_listings.map do |listing|
      {
        address: listing.address,
        property_type: listing.property_type,
        url: listing_url(listing)
      }
    end
  end
end
