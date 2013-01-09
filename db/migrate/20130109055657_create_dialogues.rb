class CreateDialogues < ActiveRecord::Migration
  def change
    create_table :dialogues do |t|
      t.boolean :initial_select
      t.boolean :opener_sent
      t.boolean :response_received

      t.timestamps
    end
  end
end
