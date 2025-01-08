# frozen_string_literal: true

class ChangeNameColumnNameInListings < ActiveRecord::Migration[7.0]
  def change
    rename_column :listings, :name, :property_type
  end
end
