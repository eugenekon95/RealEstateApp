class CreateSavedSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_searches do |t|
      t.references :search, index: true, null: false
      t.references :user, index: true, null: false
      t.index [:search_id, :user_id], unique: true
      t.timestamps
    end
  end
end
