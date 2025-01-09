class ListingMailer < ApplicationMailer
  def update_favorite_listing
    @listing = params[:listing]
    mail(to: @user.email, subject: 'Your Favorite Listing Was Updated')
  end

  def saved_searches_reminder(user:, listings:, search:)
    @user = user
    @listings = listings
    @search = search
    @saved_searches_url = saved_searches_url
    @brokerage_name = Brokerage.find(@search.brokerage_id).name if @search.brokerage_id
    mail(to: @user.email, subject: 'There were updates in your saved search')
  end
end
