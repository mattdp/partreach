class AddVarsToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :displayable, :boolean
    add_column :reviews, :supplier_id, :integer
  end
end
