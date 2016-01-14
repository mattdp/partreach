require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

#draws heavily on obfuscate_data.rake
#uses id a lot since some things have to be unique for site to work
desc 'replace sensitive, non-Synapse data with nonsense'
task :hide_all_but_synapse_data => :environment do

  synapse_org_id = 7

  ### Changed for all data

  Event.find_each do |event|
    event.destroy
  end

  Lead.find_each do |lead|
    lead.next_contact_date = nil
    lead.next_contact_content = nil
    lead.notes = nil
    lead.priority = nil
    lead.next_contactor = nil
    lead.how_found_us = nil

    lead.save(validate: false)
  end

  ### Changed for old site data

  Address.where(place_type: "User").map{|a| a.destroy}

  old_types = ["Part", "Supplier", "Machine", "Order"]
  External.where(consumer_type: old_types).map{|e| e.destroy}

  Order.find_each do |order|
    order.name = "#{order.id}"
    order.recommendation = "#{order.id}"
    order.supplier_message = "#{order.id}"
    order.recommendation = "#{order.id}"
    order.material_message = "#{order.id}"
    order.next_steps = "#{order.id}"
    order.suggested_suppliers = "#{order.id}"
    order.notes = "#{order.id}"
    order.email_snippet = "#{order.id}"
    order.order_description = "#{order.id}"
    order.process_confidence = "#{order.id}"

    order.save(validate: false)
  end

  OrderGroup.find_each do |og|
    og.name = "#{og.id}"
    og.process = "#{og.id}"
    og.material = "#{og.id}"
    og.parts_snippet = "#{og.id}"
    og.images_snippet = "#{og.id}"

    og.save(validate: false)
  end

  Part.find_each do |part|
    part.quantity = 0
    part.name = "#{part.id}"
    part.bom_identifier = "#{part.id}"
    part.material = "#{part.id}"
    part.notes = "#{part.id}"

    part.save(validate: false)
  end

  ### Changes for non-Synapse new site data
  Address.where(place_type: "Provider").each do |address|
    p = Provider.where(id: address.place_id)
    if (p.present? and p[0].organization_id == synapse_org_id)
      "Synapse"
    else
      address.street = "#{address.id}"
      address.city = "#{address.id}"
      address.notes = "#{address.id}"

      address.save(validate: false)
    end
  end

  #only "Provider" and "Comment" consumer_types left
  External.find_each do |external|
    if external.consumer_type == "Provider"
      p = Provider.where(id: external.consumer_id)
      external.destroy unless p.present?
      external.destroy unless (p[0].organization_id == synapse_org_id)
    else
      c = Comment.where(id: external.consumer_id)
      external.destroy unless c.present?
      p = c[0].provider
      external.destroy unless p.present?
      external.destroy unless (p.organization_id == synapse_org_id)
    end
  end

  other_users = User.all.reject{|u| u.team.present? and u.team.organization.present? and u.team.organization.id == synapse_org_id}
  other_users.each do |user|
    user.password_digest = "#{user.id}"

    user.save(validate: false)

    if (user.lead.present? and user.lead.lead_contact.present?)
      contact = user.lead.lead_contact
      contact.first_name = "#{contact.id}"
      contact.last_name = "#{contact.id}"
      contact.name = "#{contact.id}"
      contact.phone = "#{contact.id}"
      contact.email = "#{contact.id}"
      contact.notes = "#{contact.id}"
      contact.title = "#{contact.id}"
      contact.company = "#{contact.id}"
      contact.linkedin_url = "#{contact.id}"
      contact.cc_emails = "#{contact.id}"

      contact.save(validate: false)      
    end
  end

  other_orgs = Organization.all.reject{|o| o.id == synapse_org_id}
  other_orgs.each do |organization|

    organization.name = "#{organization.id}"
    organization.people_are_called = "#{organization.id}"
    organization.external_bucket_name = "#{organization.id}"
    organization.external_bucket_env_var_access = "#{organization.id}"
    organization.external_bucket_env_var_secret = "#{organization.id}"

    organization.save(validate: false)

    organization.teams.each do |team|
      team.name = "#{team.id}"

      team.save(validate: false)
    end

    organization.projects.each do |project|
      project.name = "#{project.id}"
      project.description = "#{project.id}"

      project.save(validate: false)
    end

    organization.tags.each do |tag|
      tag.name = "#{tag.id}"
      tag.family = "#{tag.id}"
      tag.note = "#{tag.id}"
      tag.readable = "#{tag.id}"
      tag.name_for_link = "#{tag.id}"

      tag.save(validate: false)
    end

    organization.providers.each do |provider|
      provider.name = "#{provider.id}"
      provider.url_main = "#{provider.id}"
      provider.source = "#{provider.id}"
      provider.name_for_link = "#{provider.id}"
      provider.contact_qq = "#{provider.id}"
      provider.contact_wechat = "#{provider.id}"
      provider.contact_phone = "#{provider.id}"
      provider.contact_email = "#{provider.id}"
      provider.contact_name = "#{provider.id}"
      provider.contact_role = "#{provider.id}"
      provider.city = "#{provider.id}"
      provider.location_string = "#{provider.id}"
      provider.contact_skype = "#{provider.id}"
      provider.organization_id = "#{provider.id}"
      provider.organization_private_notes = "#{provider.id}"
      provider.external_notes = "#{provider.id}"
      provider.import_warnings = "#{provider.id}"
      provider.supplybetter_private_notes = "#{provider.id}"
      provider.name_in_purchasing_system = "#{provider.id}"

      provider.save(validate: false)

      provider.comments.each do |comment|
        comment.payload = "#{comment.id}"
        comment.title = "#{comment.id}"

        comment.save(validate: false)
      end

      provider.purchase_orders.each do |po|
        po.price = 0
        po.quantity = 0
        po.description = "#{po.id}"

        po.save(validate: false)
      end

    end

  end
end