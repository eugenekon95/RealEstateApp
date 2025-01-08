class InquiriesController < ApplicationController
  before_action :set_listing, only: %i[new create]
  before_action :authorize_access, only: %i[index]

  def index
    @grouped_inquiries = Inquiry.includes(:listing)
                                .where('recievers @> ?', "{#{current_user.email}}")
                                .order(created_at: :desc)
                                .group_by(&:listing)
  end

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = @listing.inquiries.new(inquiry_params.merge(recievers: recievers))

    if @inquiry.save
      InquirySendingJob.perform_later(@listing, @inquiry)
      redirect_to listing_path(@listing), notice: 'Inquiry was sent.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def authorize_access
    return if current_user&.agent?

    redirect_to root_path, alert: 'Not authorized'
  end

  def recievers
    @listing.users.pluck(:email)
  end

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :message)
  end
end
