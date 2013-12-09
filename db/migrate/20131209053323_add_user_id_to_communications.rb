class AddUserIdToCommunications < ActiveRecord::Migration
  def change
    add_column :communications, :user_id, :integer
  end
end
