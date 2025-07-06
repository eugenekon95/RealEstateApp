class ListingForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Naming

  attr_accessor :current_user, :listing

  attribute :property_type, :string
  attribute :unit_type, :string
  attribute :description, :string
  attribute :address, :string
  attribute :city, :string
  attribute :bedrooms_quantity, :integer
  attribute :price, :integer
  attribute :status, :string
  attribute :user_ids, default: []
  attribute :pictures, default: []

  validates :property_type, :unit_type, :description, :city, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def initialize(attributes = {}, listing: nil, current_user: )
    @listing = listing || Listing.new
    @current_user = current_user
    super(attributes)
  end

  def save
    return false unless valid?

    attrs = attributes.except(:pictures)
    listing.assign_attributes(attrs)
    listing.user_ids = validated_user_ids


    if listing.save
      listing.pictures.attach(pictures) if pictures.any?
      true
    else
      errors.merge!(listing.errors)
      false
    end
  end

  def update
    return false unless valid?

    attrs = attributes.except(:pictures)
    listing.assign_attributes(attrs)
    listing.user_ids = validated_user_ids

    if listing.save
      listing.pictures.attach(pictures) if pictures.any?
      true
    else
      errors.merge!(listing.errors)
      false
    end
  end

  def agents
    @agents ||= User.where(brokerage_id: current_user.brokerage_id)
  end

  private

  def attributes_for_model
    {
      property_type:,
      unit_type:,
      description:,
      address:,
      city:,
      bedrooms_quantity:,
      price:,
      status:
    }
  end

  def validated_user_ids
    valid_ids = agents.pluck(:id)
    user_ids.map(&:to_i) & valid_ids
  end

  def attach_pictures
    # Optional: remove old pictures before attaching new ones
    listing.pictures.purge_later if listing.pictures.attached?
    listing.pictures.attach(pictures)
  end
end
