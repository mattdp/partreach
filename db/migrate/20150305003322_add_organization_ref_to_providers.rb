class AddOrganizationRefToProviders < ActiveRecord::Migration
  def change
    add_reference :providers, :organization, index: true

    reversible do |dir|
      dir.up do
        hax_id = Organization.find_by_name("HAX").id
        Provider.update_all organization_id: hax_id
      end
      change_column_null :providers, :organization_id, false
    end
  end
end
