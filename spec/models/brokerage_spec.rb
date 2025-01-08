# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Brokerage, type: :model do
  it { is_expected.to have_many :users }
  describe 'validations' do
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }

    it 'is not valid without name' do
      brokerage = build :brokerage, name: nil
      expect(brokerage).to be_invalid
      expect(brokerage.errors.messages_for(:name)).to eq(["can't be blank",
                                                          'is too short (minimum is 3 characters)'])
    end

    it 'is not valid without an address' do
      brokerage = build :brokerage, address: nil
      expect(brokerage).to be_invalid
      expect(brokerage.errors.messages_for(:address)).to eq(["can't be blank"])
    end

    it 'is not valid without city' do
      brokerage = build :brokerage, city: nil
      expect(brokerage).to be_invalid
      expect(brokerage.errors.messages_for(:city)).to eq(["can't be blank"])
    end
  end
end
