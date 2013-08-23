class AddRealToAsks < ActiveRecord::Migration
  def change
    add_column :asks, :real, :boolean
  end
end
