class AddCityToListings < ActiveRecord::Migration[7.0]
  def change
    add_column :listings, :city, :string
  end
end
