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
    mail( to: supplier.email, 
          from: "supplier-reachouts@supplybetter.com", 
          subject:"Customers want to know more about #{supplier.name} on #{brand_name}!") do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: "Customers want to know more about #{supplier.name} on #{brand_name}!", 
                              supplier: supplier} 
                            }
    end
  end
  #takes array of suppliers
  def supplier_profile_reachout_sender(suppliers,validate=true)
    suppliers.each do |s|
      if !validate or !s.has_event_of_request("profile_reachout_sent")
        b = BlastMailer.supplier_profile_reachout(s)
        b.deliver
      else
        logger.debug "Not sending to #{s.name}, event shows it was sent already"
      end
    end
    return "Sending attempted"
  end

  def test_for_layout
    @title = "Test title"
    m = mail(to: "matt@supplybetter.com", from: "supplier-reachouts@supplybetter.com", subject:"test email!") do |format|
      format.html { render layout: "layouts/blast_mailer", locals: {title: "Test title", supplier: nil} }
    end
  end

end