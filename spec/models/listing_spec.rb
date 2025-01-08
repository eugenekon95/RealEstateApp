# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Listing, type: :model do
  describe 'validations' do
    it { is_expected.to have_and_belong_to_many :users }
    it { is_expected.to validate_presence_of(:property_type) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_size_of(:pictures).less_than(10.megabytes) }
    it 'is not valid without property_type' do
      listing = build :listing, property_type: nil
      expect(listing).to be_invalid
      expect(listing.errors.messages_for(:property_type)).to eq(["can't be blank",
                                                                 'is too short (minimum is 3 characters)'])
    end

    it 'is not valid without an address' do
      listing = build :listing, address: nil
      expect(listing).to be_invalid
      expect(listing.errors.messages_for(:address)).to eq(["can't be blank", 'is too short (minimum is 5 characters)'])
    end

    it 'is not valid without price' do
      listing = build :listing, price: nil
      expect(listing).to be_invalid
      expect(listing.errors.messages_for(:price)).to eq(["can't be blank", 'is not a number'])
    end

    it 'is not valid without description' do
      listing = build :listing, description: nil
      expect(listing).to be_invalid
      expect(listing.errors.messages_for(:description)).to eq(["can't be blank"])
    end

    it 'is not valid without users' do
      listing = build :listing, users: []
      expect(listing).to be_invalid
      expect(listing.errors.messages_for(:listing)).to eq(["must have at least one agent"])
    end

    it 'creates listing with agents' do
      listing = build(:listing)
      expect(listing.valid?).to eq(true)
    end
  end
end
