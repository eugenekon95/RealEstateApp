class AddUnitTypeColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :listings, :unit_type, :integer, default: 0
  end
end
