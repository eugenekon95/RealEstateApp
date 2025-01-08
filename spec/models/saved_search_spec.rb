require 'rails_helper'

RSpec.describe SavedSearch, type: :model do
  context 'validations' do
    let(:user) { create :user }
    let(:search) { Search.create(order: 'Newest') }
    let!(:saved_search) { create :saved_search, user: user, search: search }

    it 'is not valid if user on search scope is not unique' do
      duplicate_search = build(:saved_search, user: user, search: search)

      expect(duplicate_search).to be_invalid
      expect(duplicate_search.errors.messages_for(:user)).to eq(['This search has already been saved.'])
    end

    it 'is valid if user on search scope is unique' do
      first_search = Search.create(order: 'Newest', min_price: 0)
      search_user_binding = SavedSearch.new(user: user, search: first_search)

      expect(search_user_binding).to be_valid
    end
  end
end
