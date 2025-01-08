# frozen_string_literal: true

class ChangePriceColumnTypeInListings < ActiveRecord::Migration[7.0]
  def up
    change_column :listings, :price, :integer
  end

  def down
    change_column :listings, :price, :float
  end
end
