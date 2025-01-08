require 'rails_helper'

describe 'SavedSearches', type: :request do

  describe 'GET /index' do
    context 'when user regular' do
      it 'returns http success' do
        regular = create :user, :regular
        sign_in(regular)

        get saved_searches_path
        expect(response).to be_successful
      end
    end

    context 'when user admin' do
      it 'returns http success' do
        admin = create :user, :admin
        sign_in(admin)

        get saved_searches_path
        expect(response).to be_successful
      end
    end

    context 'when user agent' do
      it 'returns http success' do
        agent = create :user, :agent
        sign_in(agent)

        get saved_searches_path
        expect(response).to be_successful
      end
    end

    context 'when not logged_in user' do
      it 'returns http redirect' do
        get saved_searches_path
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST /create' do
    context 'when user regular' do
      it 'creates a new search' do
        regular = create :user, :regular
        sign_in(regular)
        expect do
          post saved_searches_url, params:
            { max_price: 10_000,
              user_ids: [regular.id]
            }
        end.to change(Search, :count).by(1).and change(SavedSearch, :count).by(1)
      end
    end

    context 'when user admin' do
      it 'creates a new search' do
        admin = create :user, :admin
        sign_in(admin)
        expect do
          post saved_searches_url, params:
            { max_price: 10_000,
              user_ids: [admin.id]
            }
        end.to change(Search, :count).by(1).and change(SavedSearch, :count).by(1)
      end
    end

    context 'when user agent' do
      it 'creates a new search' do
        agent = create :user, :agent
        sign_in(agent)
        expect do
          post saved_searches_url, params:
            { max_price: 10_000,
              user_ids: [agent.id]
            }
        end.to change(Search, :count).by(1).and change(SavedSearch, :count).by(1)

      end
    end

    context 'when not logged_in user' do
      it 'doesn`t create new search' do
        agent = create :user, :agent
        expect do
          post saved_searches_url, params:
            {
              search: attributes_for(:search, { user_ids: [agent.id] })
            }
        end.to change(Search, :count).by(0)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'When logged_in user' do
      let(:search) { create :search }
      let(:agent) { create :user, :agent }
      let!(:saved_search) { SavedSearch.create(search: search, user: agent) }
      it 'deletes search-user-association' do
        sign_in(agent)
        expect { delete saved_search_path(saved_search) }.to change(SavedSearch, :count).by(-1)
        expect(response).to redirect_to(saved_searches_url)
      end
    end
    context 'when not logged_in user' do
      it 'doesn`t delete search-user-association' do
        agent = create :user, :agent
        search = create :search, min_price: nil, max_price: nil, users: [agent]
        expect { delete saved_search_path(search.id) }.to change(SavedSearch, :count).by(0)
      end
    end
  end
end
