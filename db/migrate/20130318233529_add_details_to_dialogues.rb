class AddDetailsToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :material, :string
    add_column :dialogues, :process_name, :string
    add_column :dialogues, :process_cost, :decimal, :precision => 10, :scale => 2
    add_column :dialogues, :process_time, :string
    add_column :dialogues, :shipping_name, :string
    add_column :dialogues, :shipping_cost, :decimal, :precision => 10, :scale => 2
    add_column :dialogues, :total_cost, :decimal, :precision => 10, :scale => 2
    add_column :dialogues, :notes, :string
  end
end