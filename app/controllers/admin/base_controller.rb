# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :admin_user

    protected

    def admin_user
      if current_user.try(:admin?)
        flash.now[:success] = 'Signed in as admin'
      else
        redirect_to root_path
      end
    end
  end
end
