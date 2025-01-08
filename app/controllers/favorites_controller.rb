# frozen_string_literal: true

class FavoritesController < ApplicationController
  before_action only: %i[index create destroy] do
    redirect_to listings_path, notice: 'Not allowed to perform this action' unless current_user
  end
  before_action :set_favorite, only: %i[destroy]

  def index
    @favorites = current_user.favorites.includes(listing: { pictures_attachments: :blob })
  end

  def create
    @favorite = Favorite.create(
      user: current_user,
      listing_id: params[:listing_id]
    )
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to favorites_url, notice: 'Favorite was successfully created.' }
    end
  end

  def destroy
    if @favorite
      @favorite.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to favorites_url, notice: 'Favorite was successfully destroyed.' }
      end
    else
      redirect_to root_path
    end
  end

  private

  def set_favorite
    @favorite = current_user.favorites.find_by(listing_id: params[:id])
  end
end

