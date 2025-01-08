# frozen_string_literal: true

class AgentListingsController < ApplicationController
  before_action :set_agent
  helper_method :access_granted

  def index
    @listings = @agent.listings.order(created_at: :desc).includes(:open_houses).page(params[:page])
  end

  private

  def set_agent
    @agent = User.find(params[:id])
  end

  def access_granted(listing)
    current_user&.brokerage_id == listing.users.first.brokerage_id
  end
end
