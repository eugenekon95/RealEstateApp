# frozen_string_literal: true

class User < ApplicationRecord
  has_and_belongs_to_many :listings
  has_many :favorites
  belongs_to :brokerage, optional: true
  has_many :mailer_subscriptions

  validates :brokerage, absence: true, unless: ->(user) { user.agent? }
  validates :brokerage,
            presence: true,
            if: ->(user) { user.agent? }

  has_many :saved_searches
  has_many :searches, through: :saved_searches

  validate :admin_presence, on: :update, if: ->(user) { user.role_was == 'admin' && user.role != 'admin' }
  validate :listing_membership, on: :update, if: ->(user) { user.role_was == 'agent' && user.role != 'agent' }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { regular: 0, agent: 1, admin: 2 }, default: :regular

  private

  def admin_presence
    admins = User.admin
    errors.add(:admin, 'at least one admin required') if !admin? && admins.size == 1
  end

  def listing_membership
    if listings.any?
      errors.add(:role, 'can`t be changed! Agent is listing owner.')
    end
  end
end
