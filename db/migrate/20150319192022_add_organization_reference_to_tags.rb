class AddOrganizationReferenceToTags < ActiveRecord::Migration
  def change
    add_reference :tags, :organization, index: true
  end
end
