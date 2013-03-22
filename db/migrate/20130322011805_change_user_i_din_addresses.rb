class ChangeUserIDinAddresses < ActiveRecord::Migration
  def change
  	rename_column :addresses, :user_id, :place_id
  end
end
