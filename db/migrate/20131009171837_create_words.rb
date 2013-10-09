class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :shortform
      t.string :longform
      t.string :name_for_link

      t.timestamps        
    end
  end
end
