class AddProcessConfidenceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :process_confidence, :string
  end
end
