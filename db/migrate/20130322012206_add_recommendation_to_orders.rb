class AddRecommendationToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :recommendation, :string
  end
end