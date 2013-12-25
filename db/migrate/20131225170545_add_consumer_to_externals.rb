class AddConsumerToExternals < ActiveRecord::Migration
  def change
    add_column :externals, :consumer_id, :integer
    add_column :externals, :consumer_type, :string
  end
end
