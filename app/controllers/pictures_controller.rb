class PicturesController < ApplicationController
  before_action :find_listing, only: :destroy
  before_action :authorize_record, only: :destroy

  def destroy
    picture = ActiveStorage::Attachment
                .where(record_id: @listing)
                .find(params[:id])
    picture.purge
    redirect_to root_path, status: :see_other, notice: 'Picture was successfully destroyed'
  end

  private

  def find_listing
    @listing = Listing.find(params[:listing_id])
  end

  def authorize_record
    return if current_user&.brokerage == @listing.users.first.brokerage

    redirect_to root_path, alert: 'Not authorized to delete this image.'
  end
end
