class MailerSubscription < ApplicationRecord
  belongs_to :user

  validates :subscribed, inclusion: { in: [true, false], message: 'must be a true or false value' }
  validates :user, uniqueness: { scope: :mailer }
end
