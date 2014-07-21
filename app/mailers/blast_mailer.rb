###
# FUTURE BLAST MAIL NEEDS TO TAKE LEAD AND USER EMAIL UNSUBS INTO ACCOUNT
###

class BlastMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com"
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
          cc: "partreach@gmail.com",
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
    @name = nil
    if target_class == "User" and target.name.present? and match_data = /^([A-Z]{1}\w+)\s{1}[\w-]+$/.match(target.name)
      @name = match_data[1]
    end

    subject = "Better RFQ Flow and 3D Printing Machine Comparison"

    address = Mail::Address.new "matt@supplybetter.com"
    address.display_name = "SupplyBetter"

    mail(to: target.email,
          from: address.format,
          subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject,
                              supplier: nil 
                            } 
                  }
    end
  end

  #targets: array of contacts, whose contactables are models that communications can attach to
  #method: way of calling the single email sender for this mail
  def general_sender(contacts,method,validate=true)
    contacts.each do |contact|
      if !validate || (
          contact.email_valid &&
          contact.email_subscribed &&
          contactable = contact.contactable &&
          !Communication.has_communication?(contactable,method.to_s)
          )
        letter = BlastMailer.send(method,contact)
        letter.deliver
        Communication.create({
          means_of_interaction: 'email',
          interaction_title: method.to_s,
          communicator_type: contactable.class.to_s,
          communicator_id: contactable.id
          })
      else
        logger.debug "Not sending to #{contactable.class.to_s} #{contactable.id}, communication shows it was sent already"
      end
    end
    return "Sending attempted"
  end

  def cold_meche_reachout_april2014(contact)
    mail(to: contact.email, subject: "cold meche test") do |format|
      format.html { render layout: "layouts/blast_mailer", locals: {title: "test title", supplier: nil} }
    end
  end

  def blog_post_april1614(contact)
    @title = "The 13 most common 3D printing methods explained"
    @salutation = contact.salutation
    mail(to: contact.email, subject: @title) do |format|
      format.html { render layout: "layouts/blast_mailer", locals: {title: @title, supplier: nil} }
    end
  end

  def blog_post_july2114(contact)
    @title = "The 6 Ways to Not Burn a New Supplier"
    @salutation = contact.salutation
    mail(to: contact.email, subject: @title) do |format|
      format.html { render layout: "layouts/blast_mailer", locals: {title: @title, supplier: nil} }
    end
  end

  def test_for_layout
    @title = "Test title"
    m = mail(to: "matt@supplybetter.com", from: "supplier-reachouts@supplybetter.com", subject:"test email!") do |format|
      format.html { render layout: "layouts/blast_mailer", locals: {title: "test test test is best", supplier: nil} }
    end
  end

end