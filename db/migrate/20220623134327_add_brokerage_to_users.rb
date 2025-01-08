class AddBrokerageToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :brokerage, foreign_key: true
  end
end
