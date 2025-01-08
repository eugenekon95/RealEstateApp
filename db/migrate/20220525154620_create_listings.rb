# frozen_string_literal: true

class CreateListings < ActiveRecord::Migration[7.0]
  def change
    create_table :listings do |t|
      t.string :name
      t.string :address
      t.text :description
      t.float :price
      t.string :type
      t.string :status
      t.timestamps
    end
  end
end
