class RemoveUnitTypeColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :listings, :unit_type
  end
end
