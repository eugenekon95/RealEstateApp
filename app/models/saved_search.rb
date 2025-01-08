class SavedSearch < ApplicationRecord
  belongs_to :search
  belongs_to :user

  validates :user, uniqueness: {
    scope: :search,
    message: 'This search has already been saved.'
  }
end
