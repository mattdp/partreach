class AddImagesSnippetToOrderGroups < ActiveRecord::Migration
  def change
    add_column :order_groups, :images_snippet, :text
    rename_column :order_groups, :email_snippet, :parts_snippet
  end
end
