class AddPurchaseOrderRefToComments < ActiveRecord::Migration
  def change
    add_column :comments, :purchase_order_id, :integer    
  end
end
