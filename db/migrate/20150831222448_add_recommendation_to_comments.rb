class AddRecommendationToComments < ActiveRecord::Migration
  def change
    add_column :comments, :recommendation, :string
  end
end
