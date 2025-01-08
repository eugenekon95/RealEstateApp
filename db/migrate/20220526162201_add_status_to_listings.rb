# frozen_string_literal: true

class AddStatusToListings < ActiveRecord::Migration[7.0]
  def change
    add_column :listings, :status, :integer, default: 0
  end
end
