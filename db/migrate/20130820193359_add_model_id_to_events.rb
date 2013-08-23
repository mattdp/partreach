class AddModelIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :model_id, :integer
  end
end
