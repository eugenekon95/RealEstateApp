class Inquiry < ApplicationRecord
  belongs_to :listing

  validates :name, presence: true
  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :message, presence: true, length: { minimum: 10 }
  validates :recievers, presence: true
end
