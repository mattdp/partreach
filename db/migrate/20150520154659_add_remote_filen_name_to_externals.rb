class AddRemoteFilenNameToExternals < ActiveRecord::Migration
  def change
    add_column :externals, :remote_file_name, :string
  end
end
