class CreateListingUsers < ActiveRecord::Migration[7.0]
  def up
    create_table :listings_users do |t|
      t.references :listing, index: true, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end

    Listing.all.find_each do |listing|
      listing.update(users: [User.find(listing.user_id)]) if listing.user_id
    end

    remove_column :listings, :user_id
  end

  def down
    add_reference :listings, :user, null: true, foreign_key: true

    Listing.find_each do |listing|
      listing.update(user_id: listing.user_ids.first)
    end

    change_column_null :listings, :user_id, false

    drop_table :listing_users
  end
end
