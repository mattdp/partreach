class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :url
      t.string :zipcode

      t.timestamps
    end
  end
end
