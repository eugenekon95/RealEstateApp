class ApplicationMailer < ActionMailer::Base
  default from: 'estateryapp@gmail.com'
  layout 'mailer'

  before_action :set_user
  before_action :set_unsubscribe_url

  private

  def set_user
    @user = params[:user]
  end

  def set_unsubscribe_url
    @unsubscribe_url = edit_mailer_subscription_url(@user, params: { mailer: self.class })
  end
end

