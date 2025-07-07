class SearchNotificationJob < ApplicationJob
  queue_as :default
  LISTINGS_NUMBER = 10

  def perform
    saved_searches = SavedSearch.where(subscribed: true).includes(:search, :user)
    saved_searches.each do |saved_search|
      search_params = saved_search.search.attributes.symbolize_keys
      filtered_params = FilterParamsService.new(search_params.merge(job_limit_params)).call
      listings = SearchListingsService.new(filtered_params).call.limit(LISTINGS_NUMBER)
      next if listings.empty?
      ListingMailer.with(user: saved_search.user, listings: listings.to_a, search: saved_search.search).saved_searches_reminder.deliver_later
    end
  end

  private

  def job_limit_params
    {
      updated_at: { gt: 1.day.ago }
    }
  end
end
