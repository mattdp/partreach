class SpecifyOverrideAverageValuePrecision < ActiveRecord::Migration
  def change
    change_column :orders, :override_average_value, :decimal, :precision => 10, :scale => 2
  end
end
