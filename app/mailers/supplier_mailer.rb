class SupplierMailer < ActionMailer::Base
  default from: "rob@supplybetter.com",
          bcc: "partreach@gmail.com"
  include SessionsHelper

  def initial_supplier_email(dialogue)
    @supplier = dialogue.supplier
    @contact = @supplier.rfq_contact

    content = dialogue.initial_email_generator
    @subject = content[:subject]
    @body = content[:body]

    mail(to: @contact.email, subject: @subject).deliver do |format|
      format.html { render layout: "layouts/supplier_mailer", 
                    locals: { title: @subject, supplier: @supplier} 
                  }
    end
  end

  def generic_quote_ended_email(dialogue)
    @supplier = dialogue.supplier
    @contact = @supplier.rfq_contact

    content = dialogue.generic_quote_ended_email_generator
    @subject = content[:subject]
    @body = content[:body]

    mail(to: @contact.email, subject: @subject).deliver do |format|
      format.html { render layout: "layouts/supplier_mailer" }
    end
  end

end