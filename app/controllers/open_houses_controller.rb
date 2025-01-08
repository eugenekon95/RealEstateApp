class OpenHousesController < ApplicationController
  before_action :set_listing
  before_action :upcoming_open_houses, only: %i[new create]
  before_action :set_open_house, only: %i[edit update destroy]
  before_action :authorize_access, only: %i[new create edit update destroy]

  def new
    @open_house = @listing.open_houses.new
  end

  def create
    @open_house = @listing.open_houses.new(open_house_params)

    if @open_house.save
      redirect_to listings_path, notice: 'Open House was added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @open_house.update(open_house_params)
      redirect_to listings_path, notice: 'Open House was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @open_house.destroy
    redirect_to listings_path, notice: 'Open House was successfully destroyed.'
  end

  private

  def upcoming_open_houses
    @upcoming_open_houses = @listing.open_houses.upcoming
  end

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def set_open_house
    @open_house = @listing.open_houses.find(params[:id])
  end

  def open_house_params
    params.require(:open_house).permit(:date, :start_time, :end_time, :listing_id)
  end

  def authorize_access
    return if current_user&.brokerage == @listing.users.first.brokerage

    redirect_to listings_path, alert: 'Not authorized to manage openhouses.'
  end
end
