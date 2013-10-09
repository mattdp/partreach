class AddFamilyToWords < ActiveRecord::Migration
  def change
    add_column :words, :family, :string
  end
end
