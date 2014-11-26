class AddMaterialAndNotesToPart < ActiveRecord::Migration
  def change
    add_column :parts, :material, :text
    add_column :parts, :notes, :text
  end
end
