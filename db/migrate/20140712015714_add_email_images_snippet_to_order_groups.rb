class AddEmailImagesSnippetToOrderGroups < ActiveRecord::Migration
  def change
    add_column :order_groups, :email_images_snippet, :text
  end
end
