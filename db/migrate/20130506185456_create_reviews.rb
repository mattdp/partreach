class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :company
      t.string :process
      t.string :part_type
      t.boolean :would_recommend
      t.integer :quality
      t.integer :adaptability
      t.integer :delivery
      t.text :did_well
      t.text :did_badly
      t.integer :user_id

      t.timestamps
    end
  end
end
