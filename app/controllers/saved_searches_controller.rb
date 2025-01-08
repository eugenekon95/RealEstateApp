class SavedSearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saved_search, only: %i[update destroy]

  def index
    @saved_searches = current_user.saved_searches.includes(:search)
    @brokerages_names_by_id = Brokerage.where(id: @saved_searches.map { |saved_search| saved_search.search.brokerage_id }).pluck(:id, :name).to_h
  end

  def create
    search = Search.find_or_create_by(search_params.transform_values(&:presence))
    saved_search = SavedSearch.new(search: search, user: current_user)

    if saved_search.save
      flash[:notice] = 'Search criteria were successfully saved.'
    else
      flash[:alert] = 'Something went wrong.'
    end

    redirect_to listings_path(params: saved_search.search.attributes.except('id', 'updated_at', 'created_at'))
  end

  def update
    if @saved_search.update(saved_search_params)
      flash[:notice] = 'Subscription was successfully updated.'
    else
      flash[:alert] = 'Something went wrong.'
    end

    redirect_back fallback_location: saved_searches_path
  end

  def destroy
    if @saved_search&.destroy
      flash[:notice] = 'Search successfully removed from saved searches'
    else
      flash[:alert] = 'Something went wrong.'
    end

    redirect_to saved_searches_url
  end

  private

  def set_saved_search
    @saved_search = current_user.saved_searches.find(params[:id])
  end

  def search_params
    params.permit(:min_price, :max_price, :city, :min_bedrooms, :brokerage_id, :order, :open_house)
  end

  def saved_search_params
    params.permit(:subscribed)
  end
end
