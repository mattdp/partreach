class AddAttachmentDrawingToOrders < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.attachment :drawing
    end
  end

  def self.down
    drop_attached_file :orders, :drawing
  end
end
