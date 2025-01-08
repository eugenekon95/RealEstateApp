class RemoveSaleTypeColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :listings, :sale_type
  end
end
