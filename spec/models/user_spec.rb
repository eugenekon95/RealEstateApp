# frozen_string_literal: true

require 'rails_helper'
RSpec.describe User, type: :model do
  it 'is not valid without email' do
    user = build :user, email: nil
    expect(user).to be_invalid
    expect(user.errors.messages_for(:email)).to eq(["can't be blank"])
  end

  it 'is not valid without password' do
    user = build :user, password: nil
    expect(user).to be_invalid
    expect(user.errors.messages_for(:password)).to eq(["can't be blank"])
  end

  it 'does not allow to change role for last admin in db' do
    user = create :user, role: :admin
    expect { user.update(role: :regular) }.not_to change { user.reload.role }.from('admin')
    expect(user.errors.messages_for(:admin)).to eq(['at least one admin required'])
  end

  it 'does not allow to change role if agent have related listings' do
    brokerage = create :brokerage
    user = create :user, :agent, brokerage: brokerage
    listing = create :listing, users: [user]
    expect { user.update(role: :regular) }.not_to change { user.reload.role }.from('agent')
    expect(user.errors.messages_for(:role)).to eq(['can`t be changed! Agent is listing owner.'])
  end

  it 'change admin role if there are more than one admin left' do
    user = create :user, role: :admin
    create :user, :admin
    expect { user.update(role: :regular) }.to change { user.reload.role }.from('admin').to('regular')
  end
end
