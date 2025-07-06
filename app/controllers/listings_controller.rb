# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :set_listing, only: %i[edit update show]
  before_action only: %i[new create] do
    redirect_to listings_path, notice: 'Not allowed to perform this action' unless current_user&.agent?
  end
  before_action :redirect_user, unless: :authorize_access, only: %i[edit update destroy]
  before_action :upcoming_open_houses, only: :show
  helper_method :access_granted
  helper_method :form_url, :form_method



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
    @form = ListingForm.new(current_user: current_user)
  end

  def create


    @form = ListingForm.new(listing_form_params, current_user: current_user)

    if @form.save
      redirect_to listings_path, notice: 'Listing was successfully created.'
    else

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = ListingForm.new(
      listing_attributes_for_form(@listing),
      listing: @listing,
      current_user:current_user)
  end

  def update
    @form = ListingForm.new(
      listing_form_params,
      listing: @listing,
      current_user: current_user
    )

    respond_to do |format|
      if @form.update
        UpdateFavoriteNotificationsJob.perform_later(@listing) if @listing.favorites.any?
        format.html { redirect_to listing_url(@listing), notice: 'Listing was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
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

  def form_url
    @listing&.persisted? ? listing_path(@listing) : listings_path
  end

  def form_method
    @listing&.persisted? ? :patch : :post
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

  def upcoming_open_houses
    @upcoming_open_houses = @listing.open_houses.upcoming.to_a
  end

  def search_params
    params.permit(:min_price, :max_price, :city, :min_bedrooms, :brokerage_id, :order, :open_house)
  end


  def listing_attributes_for_form(listing)
    listing.slice(
      :property_type,
      :unit_type,
      :description,
      :address,
      :city,
      :bedrooms_quantity,
      :price,
      :status
    ).merge(
      user_ids: listing.user_ids,
      pictures: listing.pictures.attachments
    )
  end

  def listing_form_params
    params.require(:listing_form).permit(
      :property_type, :unit_type, :description, :address, :city,
      :bedrooms_quantity, :price, :status,
      user_ids: [], pictures: []
    )
  end
end
