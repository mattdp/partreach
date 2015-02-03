class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.string :url_main
      t.string :source, :default => "manual"
      t.string :name_for_link

      t.timestamps
    end
  end
end
