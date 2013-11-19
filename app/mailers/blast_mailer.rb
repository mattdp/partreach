class BlastMailer < ActionMailer::Base
	default from: "noreply@supplybetter.com",
          bcc: "partreach@gmail.com"
  include SessionsHelper

  def supplier_profile_reachout(supplier)
    @supplier = supplier
    @brand_name = brand_name
    @base_url = base_url
    @url_name_for_link = supplier_profile_path(supplier.name_for_link)
    @url_edit = edit_supplier_path(supplier.id)
    @asks_hash = supplier.asks_hash
    Event.add_event("Supplier",supplier.id,"profile_reachout_sent")
    mail( to: supplier.rfq_contact.email, 
          from: "supplier-reachouts@supplybetter.com", 
          subject:"Customers want to know more about #{supplier.name} on #{brand_name}!") do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: "Customers want to know more about #{supplier.name} on #{brand_name}!", 
                              supplier: supplier} 
                            }
    end
  end

  def buyer_and_lead_reachout_131120(target)
    target_class = target.class.to_s
    Event.add_event(target_class,target.id,"buyer_and_lead_reachout_131120_sent")
    target_class == "User" and target.name.present? ? @name = target.name : @name = nil
    subject = "SupplyBetter Fall Update"
    mail(to: target.email,
          from: "matt@supplybetter.com",
          subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject,
                              supplier: nil 
                            } 
                  }
    end
  end
  
  #targets: array of models
  #method: way of calling the single email sender for this mail
  #event_to_check: what happening in Event should block this
  def general_sender(targets,method,event_to_check,validate=true)
    targets.each do |t|
      if !validate or !Event.has_event?(t.class.to_s,t.id,event_to_check)
        letter = BlastMailer.send(method,t)
        letter.deliver
      else
        logger.debug "Not sending to #{t.class.to_s} #{t.id}, event shows it was sent already"
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