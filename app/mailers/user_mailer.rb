class UserMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com",
          bcc: "partreach@gmail.com"
  include SessionsHelper

  MATT =  "matt@supplybetter.com"
  ROB =   "rob@supplybetter.com"
  JAMES = "james@supplybetter.com"
  YOSSI = "yossi@supplybetter.com"
  CUSTOMER_SERVICE = "robert@supplybetter.com"
  INTERNAL_EMAIL_DISTRIBUTION_LIST = [MATT,ROB,JAMES,YOSSI,CUSTOMER_SERVICE]

  def email_internal_team(subject, note)
    @note = note
    INTERNAL_EMAIL_DISTRIBUTION_LIST.each do |e|
      mail(to: e, subject: subject).deliver do |format|
        format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      end
    end
  end

  def daily_internal_update
    subject = "#{Date.today.strftime('%Y-%m-%d')} update on SupplyBetter metrics"
    @pending = {
      "reviews" => Review.pending_examination,
      "suppliers" => Supplier.pending_examination
    }
    @incomplete_orders = Order.incomplete_orders
    @brand_name = brand_name
    @suppliers_to_bother = Supplier.next_contact_suppliers_sorted
    @leads_to_bother = Lead.sorted(false)
    @need_to_inform_suppliers_structure = Order.need_to_inform_suppliers_structure
    @duplicates_detected = Contact.duplicate_detector
    INTERNAL_EMAIL_DISTRIBUTION_LIST.each do |e|
      mail(to: e, subject: subject).deliver do |format|
        format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      end
    end
  end

  def welcome_email(user)
    @user = user
    @brand_name = brand_name
    subject = "Welcome to #{brand_name}!"
    mail(to: @user.lead.lead_contact.email, subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      format.text
    end
  end

  #VET THIS - think it's broken
  # def bid_completed_email(user,order)
  #   @user = user
  #   @order = order
  #   @url = orders_path(order)
  #   mail(to: @user.email, subject: "Your #{brand_name} quotes have arrived")
  # end

  def password_reset(user)
    @user = user
    @brand_name = brand_name
    subject = "Password reset requested"
    mail(to: @user.lead.lead_contact.email, subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      format.text
    end
  end

  def supplier_intro_email(user,supplier)
    @user = user
    @brand_name = brand_name
    @supplier = supplier
    subject = "Your new #{brand_name} account"
    mail(to: @user.lead.lead_contact.email, subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: supplier} 
                            }
      format.text
    end
  end

end
