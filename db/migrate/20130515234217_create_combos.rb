class CreateCombos < ActiveRecord::Migration
  def change
    create_table :combos do |t|
      t.integer :supplier_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
