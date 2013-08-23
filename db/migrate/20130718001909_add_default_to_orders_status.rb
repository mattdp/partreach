class AddDefaultToOrdersStatus < ActiveRecord::Migration
  def change
  	change_column :orders, :status, :string, :default => "Needs work"
  end
end
