# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :set_listing, only: %i[edit update show]
  before_action only: %i[new create] do
    redirect_to listings_path, notice: 'Not allowed to perform this action' unless current_user&.agent?
  end
  before_action :redirect_user, unless: :authorize_access, only: %i[edit update destroy]
  before_action :agents, only: %i[new create edit]
  before_action :upcoming_open_houses, only: :show
  helper_method :access_granted



  def index
    @search_params = FilterParamsService.new(params).call
    @listings = SearchListingsService.new(@search_params).call.page(params[:page])
    search = Search.find_or_create_by(search_params.transform_values(&:presence))
    @saved_search = SavedSearch.find_by(search: search, user: current_user)
    render :empty_search if @listings.blank?
  end

  def show
    user_id = session[:session_id] || session[:_csrf_token]
    TrackLastVisitedListingsService.new(user_id, @listing).call
  end

  def new
    @listing = Listing.new
  end

  def edit; end

  def create
    @listing = Listing.new(listing_params.merge(user_ids: validated_agents))

    if @listing.save
      redirect_to listings_path, notice: 'Listing was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @listing.update(listing_params.merge(user_ids: validated_agents))
        UpdateFavoriteNotificationsJob.perform_later(@listing) if @listing.favorites.any?
        format.html { redirect_to listing_url(@listing), notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def access_granted(listing)
    current_user&.brokerage_id == listing.users.first.brokerage_id
  end

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def redirect_user
    redirect_to listings_path, notice: 'Not authorized to edit this listing'
  end

  def authorize_access
    access_granted(@listing)
  end

  def agents
    @agents ||= User.where(brokerage_id: current_user.brokerage_id)
  end

  def validated_agents
    listing_params[:user_ids].compact_blank.map(&:to_i) & agents.map(&:id)
  end

  def upcoming_open_houses
    @upcoming_open_houses = @listing.open_houses.upcoming.to_a
  end

  def search_params
    params.permit(:min_price, :max_price, :city, :min_bedrooms, :brokerage_id, :order, :open_house)
  end

  def listing_params
    params.require(:listing).permit(:property_type, :unit_type, :description, :address, :city, :bedrooms_quantity,
                                    :price, :status, user_ids: [], pictures: [])
  end
end
