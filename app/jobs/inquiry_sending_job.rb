class InquirySendingJob < ApplicationJob
  queue_as :default

  def perform(listing, inquiry)
    inquiry.recievers.each do |email|
      InquiryMailer.with(to: email, inquiry: inquiry, listing: listing).inquiry.deliver_later
    end
  end
end
