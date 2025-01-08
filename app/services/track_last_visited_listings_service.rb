class TrackLastVisitedListingsService
  def initialize(user_id, listing)
    @user_id = user_id
    @listing = listing
    @type = listing.class.name
  end

  def call
    REDIS.zadd(@user_id, [Time.current.to_i, "#{@type}-#{@listing.id}"])
    REDIS.expire(@user_id, 7.days.to_i)
  end
end
