# frozen_string_literal: true

class OpenHouse < ApplicationRecord
  belongs_to :listing
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, comparison: { greater_than: :start_time }
  validate :duration
  with_options if: -> { date } do
    validate :in_future
    validate :intervals_intersection
  end
  scope :upcoming, (lambda do
    where('date > ? OR date = ? AND end_time > ?',
          Date.current,
          Date.current,
          Time.current.strftime('%T'))
      .order(date: :asc, start_time: :asc)
  end)
  after_commit :reindex_listing

  private

  def duration
    return unless end_time && start_time && (end_time - start_time) > 12.hours.to_i

    errors.add(:end_time, ':Open House event duration can not be longer than 12 hours.')
  end

  def in_future
    return if date > Date.current ||
      date == Date.current && start_time.utc.hour > Time.current.utc.hour

    errors.add(:start_time, ':Open House must begin no earlier than next hour.')
  end

  def time_intersects?(other)
    start_time >= other.start_time && start_time < other.end_time ||
      end_time > other.start_time && end_time <= other.end_time ||
      start_time <= other.start_time && end_time >= other.end_time
  end

  def intervals_intersection
    open_houses = OpenHouse.where(listing_id: listing_id, date: date).where.not(id: id)
    return if open_houses.none?(&method(:time_intersects?))

    errors.add(:base, ':this time interval intersects with some other OpenHouse event for this listing.')
  end

  def reindex_listing
    listing.reindex
  end
end
