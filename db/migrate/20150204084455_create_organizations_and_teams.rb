class CreateOrganizationsAndTeams < ActiveRecord::Migration
  def change
  
    create_table :organizations do |t|
      t.string :name

      t.timestamps
    end

    create_table :teams do |t|
      t.string :name
      t.integer :organization_id

      t.timestamps
    end

    add_column :users, :team_id, :integer

  end
end