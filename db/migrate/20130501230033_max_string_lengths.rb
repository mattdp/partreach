class MaxStringLengths < ActiveRecord::Migration
  def change
  	change_column :dialogues, :notes, :text
  	change_column :orders, :recommendation, :text
  	change_column :orders, :suggested_suppliers, :text
  end
end