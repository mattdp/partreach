class SupplierMailer < ActionMailer::Base
  default from: "rob@supplybetter.com",
          bcc: "partreach@gmail.com"
  include SessionsHelper

  def email_supplier(dialogue)
    @supplier = dialogue.supplier
    @contact = supplier.rfq_contact

    content = dialogue.initial_email_generator
    @subject = content[:subject]
    @body = content[:body]

    mail(to: @contact.email, subject: @subject).deliver do |format|
      #   format.html { render layout: "layouts/blast_mailer", 
      #               locals: { title: subject, 
      #                         supplier: nil} 
      #                       }
    end
  end

end
