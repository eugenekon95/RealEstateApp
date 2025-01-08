# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET #index' do
    context 'when authorized' do
      let(:admin) { create :user, :admin }

      before { login_as admin }

      it 'returns http success' do
        get admin_users_path

        expect(response).to be_successful
      end
    end

    context 'when not authorized' do
      context 'when current user is regular' do
        let(:regular) { create :user, :regular }

        before { login_as regular }

        it 'redirects to root path' do
          expect(get(admin_users_path)).to redirect_to root_path
        end
      end

      context 'when current user is agent' do
        let(:agent) { create :user, :agent }

        before { login_as agent }

        it 'redirects to root path' do
          expect(get(admin_users_path)).to redirect_to root_path
        end
      end

      context 'when no logged in user' do
        it 'redirects to root path' do
          expect(get(admin_users_path)).to redirect_to root_path
        end
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create :user }

    context 'when authorized' do
      let(:admin) { create :user, :admin }

      before { login_as admin }

      context 'change self role' do
        it 'does not update role' do
          patch admin_user_path(admin)
          expect(response).to have_http_status(:forbidden)
          expect(admin.reload.role).to eq('admin')
        end
      end

      context 'update other user' do
        context 'role to agent with brokerage required' do
          let(:brokerage) { create :brokerage }
          let(:params) { { user: { role: :agent, brokerage_id: brokerage.id } } }

          it 'updates user' do
            patch admin_user_path(user), params: params

            expect(user.reload.role).to eq 'agent'
            expect(user.reload.brokerage_id).to eq brokerage.id
          end
        end

        context 'role to admin' do
          let(:params) { { user: { role: :admin, brokerage_id: nil } } }

          it 'updates user' do
            patch admin_user_path(user), params: params

            expect(user.reload.role).to eq 'admin'
            expect(user.reload.brokerage_id).to be_nil
          end
        end
      end
    end

    context 'when not authorized' do
      context 'when current user is regular' do
        let(:regular) { create :user, :regular }

        before { login_as regular }

        it 'does not update user' do
          patch admin_user_path(user)

          expect(response).to redirect_to root_path
          expect(user.reload.role).to eq('regular')
        end
      end

      context 'when current user is agent' do
        let(:agent) { create :user, :agent }

        before { login_as agent }

        it 'does not update user' do
          patch admin_user_path(user)

          expect(response).to redirect_to root_path
          expect(user.reload.role).to eq('regular')
        end
      end

      context 'when no logged in user' do
        it 'does not update user' do
          patch admin_user_path(user)

          expect(response).to redirect_to root_path
          expect(user.reload.role).to eq('regular')
        end
      end
    end
  end
end
