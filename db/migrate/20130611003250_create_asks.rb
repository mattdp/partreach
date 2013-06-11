class CreateAsks < ActiveRecord::Migration
  def change
    create_table :asks do |t|
    	t.integer :supplier_id
    	t.integer :user_id
    	t.string :request

      t.timestamps
    end
  end
end
