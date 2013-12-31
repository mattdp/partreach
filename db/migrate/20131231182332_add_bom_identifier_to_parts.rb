class AddBomIdentifierToParts < ActiveRecord::Migration
  def change
    add_column :parts, :bom_identifier, :string
  end
end
