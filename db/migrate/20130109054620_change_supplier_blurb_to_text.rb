class ChangeSupplierBlurbToText < ActiveRecord::Migration
  def up
  	change_column :suppliers, :blurb, :text
  end

  def down
  	change_column :suppliers, :blurb, :string
  end
end
