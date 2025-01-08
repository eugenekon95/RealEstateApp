# frozen_string_literal: true

class SearchListingsService
  PER_PAGE = 6

  def initialize(params)
    @params = params
  end

  def call
    params = FilterParamsService.new(@params).call
    search_condition = params[:query] || '*'
    Listing.search(search_condition,
                   fields: [:city, :address], match: :word_start, misspellings: false,
                   order: params[:order],
                   where: get_search_params(params),
                   page: params[:page], per_page: PER_PAGE,
                   includes: [:closest_open_house, :favorites, { users: :brokerage }],
                   scope_results: ->(r) { r.with_attached_pictures })
  end

  private

  def get_search_params(params)
    search_params = {}
    search_params[:bedrooms_quantity] = { gte: params[:min_bedrooms] } if params[:min_bedrooms]
    search_params[:price] = (params[:min_price]..params[:max_price])
    search_params[:brokerage_id] = params[:brokerage_id] if params[:brokerage_id]
    search_params[:city] = params[:city] if params[:city]
    search_params[:open_houses_expirations] = { exists: { gte: Time.now } } if params[:closest_open_house]
    search_params
  end
end
