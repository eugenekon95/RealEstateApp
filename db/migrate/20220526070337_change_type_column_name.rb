# frozen_string_literal: true

class ChangeTypeColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :listings, :type, :unit_type
  end
end
