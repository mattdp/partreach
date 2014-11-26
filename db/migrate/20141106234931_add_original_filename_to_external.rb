class AddOriginalFilenameToExternal < ActiveRecord::Migration
  def change
    add_column :externals, :original_filename, :string
  end
end
