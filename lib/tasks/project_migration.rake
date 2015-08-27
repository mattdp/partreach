require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

desc 'create projects for all project names in app'
task :project_creator => :environment do
  PurchaseOrder.find_each do |po|
    comment = po.comment
    if (comment.present? and po.project_name.present? and comment.provider.present? and comment.provider.organization_id.present?) 
      comment.project_id = Project.find_or_create(comment.provider.organization_id,po.project_name).id
      comment.save
    end
  end
end