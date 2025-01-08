class InquiryMailer < ApplicationMailer
  def inquiry
    @recievers = params[:to]
    @inquiry = params[:inquiry]
    @listing = params[:listing]
    mail(to: @recievers, subject: 'Contact inquiry')
  end
end
