class AddBedroomsQuantityToListings < ActiveRecord::Migration[7.0]
  def change
    add_column :listings, :bedrooms_quantity, :integer, default: 0
  end
end
