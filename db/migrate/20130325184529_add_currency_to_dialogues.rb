class AddCurrencyToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :currency, :string, :default => "dollars"
  end
end
