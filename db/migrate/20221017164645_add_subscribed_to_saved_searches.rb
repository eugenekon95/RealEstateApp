class AddSubscribedToSavedSearches < ActiveRecord::Migration[7.0]
  def change
    add_column :saved_searches, :subscribed, :boolean, default: true
  end
end
