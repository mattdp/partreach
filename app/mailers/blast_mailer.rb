class BlastMailer < ActionMailer::Base
	default from: "noreply@supplybetter.com"
  include SessionsHelper

  def supplier_profile_reachout(supplier)
    @supplier = supplier
    @brand_name = brand_name
    @url_name_for_link = supplier_profile_path(supplier.name_for_link)
    @url_edit = edit_supplier_path(supplier.id)
    @asks_hash = supplier.asks_hash
    Event.add_event("Supplier",supplier.id,"profile_reachout_sent")
    mail(to: supplier.email, from: "supplier-reachouts@supplybetter.com", subject:"Customers want to know more about #{supplier.name} on #{brand_name}!")
  end
  #takes array of suppliers
  def supplier_profile_reachout_sender(suppliers,validate=true)
    suppliers.each do |s|
      if !validate or !Supplier.has_event_of_request("profile_reachout_sent")
        b = BlastMailer.supplier_profile_reachout(s)
        b.deliver
      else
        logger.debug "Not sending to #{s.name}, event shows it was sent already"
      end
    end
  end

  def basic_supplier_profile_email(email_address,subject)
    attachments.inline['pixil3d.jpg'] = File.read('./app/assets/images/profile_pixil3d.jpg')
    attachments.inline['partsnap.jpg'] = File.read('./app/assets/images/profile_partsnap.jpg')
    return mail(to: email_address, subject: subject)
  end
  def basic_supplier_profile_email_sender(addresses,subject,validate=true)
    addresses.each do |a|
      if !validate or User.can_use_email?(a)
        b = BlastMailer.blast_email(a,subject)
        b.deliver
      else
        logger.debug "Not sending to #{a}"
      end
    end
  end

end