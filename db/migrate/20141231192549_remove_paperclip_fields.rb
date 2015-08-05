class RemovePaperclipFields < ActiveRecord::Migration
  def change
    remove_column :orders, :drawing_content_type
    remove_column :orders, :drawing_file_size 
    remove_column :orders, :drawing_updated_at
  end
end
