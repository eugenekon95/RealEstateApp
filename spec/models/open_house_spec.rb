require 'rails_helper'

RSpec.describe OpenHouse, type: :model do
  context 'validations' do
    let(:open_house) { build(:open_house) }

    it 'is not valid without date' do
      open_house.date = nil

      expect(open_house).to be_invalid
      expect(open_house.errors.messages_for(:date)).to eq(['can\'t be blank'])
    end

    it 'is not valid without start_time' do
      open_house.start_time = nil

      expect(open_house).to be_invalid
      expect(open_house.errors.messages_for(:start_time)).to eq(['can\'t be blank'])
    end

    it 'is not valid without end_time' do
      open_house.end_time = nil

      expect(open_house).to be_invalid
      expect(open_house.errors.messages_for(:end_time)).to eq(['can\'t be blank'])
    end
  end

  context 'validate time interval' do
    let(:time) { Faker::Time.forward(period: :morning) }

    it 'is valid with start_time earlier than end_time' do
      open_house = build(:open_house, start_time: time, end_time: time + 1.hour)

      expect(open_house).to be_valid
    end

    it 'is not valid with start_time later than end_time' do
      open_house = build(:open_house, start_time: time, end_time: time - 1.minute)
      expect(open_house).to be_invalid
    end

    it 'is not valid with time interval longer 12 hours' do
      open_house = build(:open_house, start_time: time, end_time: time + 12.hours + 1.minute)

      expect(open_house).to be_invalid
      expect(open_house.errors.messages_for(:end_time)).to eq([':Open House event duration can not be longer than 12 hours.'])
    end
  end

  context 'validate creation in the past' do
    it 'is invalid if open house date is yesterday' do
      open_house = build(:open_house, date: Date.current - 1.day)

      expect(open_house).to be_invalid
      expect(open_house.errors.messages_for(:start_time))
        .to eq([':Open House must begin no earlier than next hour.'])
    end
  end

  context 'open_house intersection' do
    it 'is not valid if end_time covering existing open_house' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '10:00', end_time: '13:00'
      second_open_house = build :open_house, listing: listing, start_time: '08:45', end_time: '11:00',
                                             date: open_house.date
      expect(second_open_house).to be_invalid
      expect(second_open_house.errors.messages_for(:base))
        .to eq([':this time interval intersects with some other OpenHouse event for this listing.'])
    end

    it 'is invalid if start_time covering existing open_house' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '10:00', end_time: '12:00'
      second_open_house = build :open_house, listing: listing, start_time: '11:00', end_time: '14:00',
                                             date: open_house.date
      expect(second_open_house).to be_invalid
      expect(second_open_house.errors.messages_for(:base))
        .to eq([':this time interval intersects with some other OpenHouse event for this listing.'])
    end

    it 'is invalid if time interval fully covered by existing open_house time interval' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '10:00', end_time: '14:00'
      second_open_house = build :open_house, listing: listing, start_time: '11:00', end_time: '13:00',
                                             date: open_house.date
      expect(second_open_house).to be_invalid
      expect(second_open_house.errors.messages_for(:base))
        .to eq([':this time interval intersects with some other OpenHouse event for this listing.'])
    end

    it 'is invalid if time interval intersects with existing open_house time interval' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '10:00', end_time: '13:00'
      second_open_house = build :open_house, listing: listing, start_time: '09:00', end_time: '15:00',
                                             date: open_house.date
      expect(second_open_house).to be_invalid
      expect(second_open_house.errors.messages_for(:base))
        .to eq([':this time interval intersects with some other OpenHouse event for this listing.'])
    end

    it 'is valid if time interval not intersects with existing open_house' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '11:00', end_time: '14:00'
      second_open_house = build :open_house, listing: listing, start_time: '10:00', end_time: '10:50',
                                             date: open_house.date
      expect(second_open_house).to be_valid
    end

    it 'is valid if it starts after existing open_house' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '10:00', end_time: '13:00'
      second_open_house = build :open_house, listing: listing, start_time: '14:00', end_time: '15:00',
                                             date: open_house.date
      expect(second_open_house).to be_valid
    end

    it 'is valid if time intersects but date is another day' do
      listing = create :listing
      open_house = create :open_house, listing: listing, start_time: '10:00', end_time: '13:00'
      second_open_house = build :open_house, listing: listing, start_time: '10:00', end_time: '13:00',
                                             date: open_house.date + 3.days
      expect(second_open_house).to be_valid
    end
  end
end
