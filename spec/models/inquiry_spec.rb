require 'rails_helper'

RSpec.describe Inquiry, type: :model do
  it { is_expected.to belong_to(:listing) }

  let(:listing) { create :listing }

  it 'is valid with valid params' do
    inquiry = build :inquiry, listing: listing

    expect(inquiry).to be_valid
  end

  it 'is invalid without email' do
    inquiry = build :inquiry, listing: listing, email: nil

    expect(inquiry).to be_invalid
    expect(inquiry.errors.messages_for(:email)).to eq(["can't be blank", "is invalid"])
  end

  it 'is invalid without name' do
    inquiry = build :inquiry, listing: listing, name: nil
    expect(inquiry).to be_invalid
    expect(inquiry.errors.messages_for(:name)).to eq(["can't be blank"])
  end

  it 'is invalid without message' do
    inquiry = build :inquiry, listing: listing, message: nil
    expect(inquiry).to be_invalid
    expect(inquiry.errors.messages_for(:message)).to eq(["can't be blank", "is too short (minimum is 10 characters)"])
  end

  it 'is invalid without recievers' do
    inquiry = build :inquiry, listing: listing, recievers: []
    expect(inquiry).to be_invalid
    expect(inquiry.errors.messages_for(:recievers)).to eq(["can't be blank"])
  end

end
