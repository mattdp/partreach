class BasicIndexing < ActiveRecord::Migration
  def change
  	add_index :combos, :supplier_id
  	add_index :owners, :supplier_id
  	add_index :dialogues, :order_id
  end
end
