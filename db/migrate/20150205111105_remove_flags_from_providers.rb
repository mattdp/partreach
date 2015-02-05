class RemoveFlagsFromProviders < ActiveRecord::Migration
  def change
    remove_column :providers, :tag_laser_cutting
    remove_column :providers, :tag_cnc_machining
  end
end
