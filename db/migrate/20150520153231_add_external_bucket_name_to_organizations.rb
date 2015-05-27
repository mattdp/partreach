class AddExternalBucketNameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :external_bucket_name, :string
  end
end
