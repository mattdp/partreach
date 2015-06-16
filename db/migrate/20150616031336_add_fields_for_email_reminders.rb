class AddFieldsForEmailReminders < ActiveRecord::Migration
  def change
    add_column :organizations, :default_reminder_days, :integer, default: 4
    add_column :purchase_orders, :dont_request_feedback, :boolean
  end
end
