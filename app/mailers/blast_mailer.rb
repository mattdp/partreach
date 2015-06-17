class BlastMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com"
  include SessionsHelper

  #targets: array of contacts, whose contactables are models that communications can attach to
  #method: way of calling the single email sender for this mail
  #ex: BlastMailer.general_sender([Contact.find_by_email("mdpfwds@gmail.com")],:c_reachout_1412_MiddleGround,false)
  def general_sender(contacts,method,validate=true)
    contacts.each do |contact|
      contactable = contact.contactable
      if !validate || (
          contact.email_valid &&
          contact.email_subscribed &&
          !Communication.has_communication?(contactable, method.to_s)
          )
        letter = BlastMailer.send(method,contact)
        letter.deliver
        if contactable
          Communication.create({
            means_of_interaction: 'email',
            interaction_title: method.to_s,
            communicator_type: contactable.class.to_s,
            communicator_id: contactable.id
            })
        end
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

  #c = cold, but we don't want to say that in the link text
  def c_reachout_1412_MiddleGround(contact)
    @contact = contact
    @title = "#{@contact.first_name}, can you help us with our manufacturing blog for engineers?"
    m = mail(to: contact.email, from: "matt@supplybetter.com", subject: @title) do |format|
      format.html { render layout: "layouts/simple_mailer", locals: {title: @title, contact: @contact } }
    end
  end

  def c_reachout_1412_Casual(contact)
    @contact = contact
    @title = "#{@contact.first_name.downcase}, because you're an engineer"
    m = mail(to: contact.email, from: "matt@supplybetter.com", subject: @title) do |format|
      format.html { render layout: "layouts/simple_mailer", locals: {title: @title, contact: @contact } }
    end
  end

  def c_reachout_1412_3dPrinting(contact)
    @contact = contact
    @title = "#{@contact.first_name}, is this what you want to know about 3D printing?"
    m = mail(to: contact.email, from: "matt@supplybetter.com", subject: @title) do |format|
      format.html { render layout: "layouts/simple_mailer", locals: {title: @title, contact: @contact } }
    end
  end  

end