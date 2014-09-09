class AddBillableToDialouge < ActiveRecord::Migration
  def change
    add_column :dialogues, :billable, :boolean, default: false
  end
end
