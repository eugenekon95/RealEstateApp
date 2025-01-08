# frozen_string_literal: true

class AddFirstnameLastnamePhoneFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :phone, :string
  end
end
