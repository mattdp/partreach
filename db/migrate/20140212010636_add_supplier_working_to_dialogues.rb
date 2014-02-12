class AddSupplierWorkingToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :supplier_working, :boolean
  end
end
