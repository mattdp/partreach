class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.Dialogue :winning_dialogue

      t.timestamps
    end
  end
end
