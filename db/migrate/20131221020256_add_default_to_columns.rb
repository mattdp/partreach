class AddDefaultToColumns < ActiveRecord::Migration
  def change
  	change_column :orders, :columns_shown, :string, :default => "all"
  end
end
