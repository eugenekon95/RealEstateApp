# frozen_string_literal: true

class Brokerage < ApplicationRecord
  has_many :users

  validates :name, presence: true, length: { minimum: 3 }
  validates :address, presence: true
  validates :city, presence: true
end
