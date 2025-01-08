class CreateInquiries < ActiveRecord::Migration[7.0]
  def change
    create_table :inquiries do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :message, null: false
      t.references :listing
      t.text :recievers, array: true, default: []

      t.timestamps
    end
  end
end
