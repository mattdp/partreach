class AddIdWithinSourceToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :id_within_source, :integer
  end
end
