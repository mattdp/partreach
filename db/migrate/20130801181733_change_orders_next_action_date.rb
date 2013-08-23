class ChangeOrdersNextActionDate < ActiveRecord::Migration
  def change
  	change_column :orders, :next_action_date, :string
  end
end
