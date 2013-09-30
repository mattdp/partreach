class RenameCommunicationVariables < ActiveRecord::Migration
  def change
  	rename_column :communications, :type, :means_of_interaction
  	rename_column :communications, :subtype, :interaction_title
  end
end
