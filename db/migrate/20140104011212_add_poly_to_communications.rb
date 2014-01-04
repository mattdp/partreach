class AddPolyToCommunications < ActiveRecord::Migration
  def change
    add_column :communications, :communicator_id, :integer
    add_column :communications, :communicator_type, :string
  end
end
