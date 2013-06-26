class AddClaimedToProfiles < ActiveRecord::Migration
  def change
    add_column :suppliers, :claimed, :boolean, :default => false
  end
end
