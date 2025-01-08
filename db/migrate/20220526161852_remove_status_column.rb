# frozen_string_literal: true

class RemoveStatusColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :listings, :status
  end
end
