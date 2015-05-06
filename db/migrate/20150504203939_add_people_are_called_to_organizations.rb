class AddPeopleAreCalledToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :people_are_called, :string
  end
end
