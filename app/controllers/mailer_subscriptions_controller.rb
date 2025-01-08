class MailerSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mailer_subscription, only: %i[edit update]

  def edit; end

  def update
    if @mailer_subscription.update(subscribed: params[:subscribed])
      redirect_to root_path, notice: 'Subscription updated.'
    else
      redirect_to root_path, alert: 'Something went wrong'
    end
  end

  private

  def set_mailer_subscription
    @mailer_subscription = MailerSubscription.find_or_initialize_by(
      user: current_user,
      mailer: params[:mailer]
    )
  end
end
