# frozen_string_literal: true

class AddSaleTypeToListings < ActiveRecord::Migration[7.0]
  def change
    add_column :listings, :sale_type, :integer, default: 0
  end
end
