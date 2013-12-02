class RenameGeographyAssociation < ActiveRecord::Migration
  def change
  	rename_column :geographies, :containing_geography, :geography_id
  end
end

