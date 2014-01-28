class AddEmailSnippetToOrdersAndGroups < ActiveRecord::Migration
  def change
  	add_column :order_groups, :email_snippet, :text
  	add_column :orders, :email_snippet, :text
  end
end
