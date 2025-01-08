class UpdateFavoriteNotificationsJob < ApplicationJob
  queue_as :default

  def perform(listing)
    users = User.joins(:favorites)
                .where(favorites: { listing: listing })
                .left_outer_joins(:mailer_subscriptions)
                .where("(mailer = 'ListingMailer' AND subscribed = true) OR mailer_subscriptions.id IS NULL")
                .distinct

    users.each do |user|
      ListingMailer.with(user: user, listing: listing).update_favorite_listing.deliver_later
    end
  end
end
