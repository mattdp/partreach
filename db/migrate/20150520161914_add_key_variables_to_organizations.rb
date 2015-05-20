class AddKeyVariablesToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :external_bucket_env_var_access, :string
    add_column :organizations, :external_bucket_env_var_secret, :string
  end
end
