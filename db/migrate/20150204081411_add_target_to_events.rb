class AddTargetToEvents < ActiveRecord::Migration
  def change
    add_column :events, :target_model, :string
    add_column :events, :target_model_id, :integer
  end
end
