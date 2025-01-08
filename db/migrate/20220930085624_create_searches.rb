class CreateSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :searches do |t|
      t.string :city
      t.integer :min_bedrooms
      t.integer :min_price
      t.integer :max_price
      t.boolean :open_house
      t.string :order
      t.bigint :brokerage_id
      t.timestamps
    end
  end
end
