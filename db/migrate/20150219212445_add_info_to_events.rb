class AddInfoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :info, :text
  end
end
