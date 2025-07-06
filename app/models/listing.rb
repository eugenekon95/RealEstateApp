# frozen_string_literal: true

class Listing < ApplicationRecord
  has_many_attached :pictures
  has_many :open_houses
  has_one :closest_open_house, -> { upcoming }, class_name: 'OpenHouse'
  has_and_belongs_to_many :users
  has_many :inquiries
  has_many :favorites

  validates :pictures, content_type: :jpeg, size: { less_than: 10.megabytes, message: 'size must be less than 10 megabytes' }
  validates :property_type, presence: true, length: { minimum: 3 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :address, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 5 }
  validates :city, presence: true, length: { minimum: 3 }
  validates :bedrooms_quantity, presence: true, numericality: true

  enum :unit_type, { sale: 0, rental: 1 }
  enum :status, { active: 0, inactive: 1 }
  validate :agent_presence
  paginates_per 6

  searchkick word_start: [:city, :address]
  scope :search_import, -> { includes(:closest_open_house, { users: :brokerage }) }

  private

  def agent_presence
    errors.add(:listing, "must have at least one agent") if user_ids.empty?
  end

  def search_data
    {
      city: city,
      address: address,
      property_type: property_type,
      bedrooms_quantity: bedrooms_quantity,
      price: price,
      created_at: created_at,
      updated_at: updated_at,
      open_houses_expirations: open_houses.map do |open_house|
        if open_house.date >= Time.zone.today
          (open_house.date.strftime('%m-%d-%Y') +
            " " +
            open_house.end_time.strftime('%H:%M'))
        end
      end,
      brokerage_id: users.first.brokerage&.id,
    }
  end
end
