class Search < ApplicationRecord
  has_many :saved_searches
  has_many :users, through: :saved_searches
end
