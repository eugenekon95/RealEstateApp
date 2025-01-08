# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    def index
      @users = User.all.includes(:brokerage)
    end

    def show
      @user = User.find(params[:id])
    end

    def edit
      @user = User.find(params[:id])
      @brokerages = Brokerage.all
    end

    def update
      @user = User.find(params[:id])

      return head(:forbidden) if current_user.id == @user.id

      @brokerages = Brokerage.all
      @user.brokerage = find_brokerage

      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:role, :brokerage_id)
    end

    def find_brokerage
      @brokerages.find_by(id: user_params[:brokerage_id])
    end
  end
end
