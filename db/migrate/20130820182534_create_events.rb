class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :model
      t.string :happening

      t.timestamps
    end
  end
end
