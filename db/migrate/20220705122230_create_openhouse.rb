class CreateOpenhouse < ActiveRecord::Migration[7.0]
  def change
    create_table :open_houses do |t|
      t.belongs_to :listing, index: true, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.timestamps
    end
  end
end
