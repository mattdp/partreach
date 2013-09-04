class BlastMailer < ActionMailer::Base
	default from: "noreply@supplybetter.com"
  include SessionsHelper

  def blast_email(email_address,subject)
    attachments.inline['pixil3d.jpg'] = File.read('./app/assets/images/profile_pixil3d.jpg')
    attachments.inline['partsnap.jpg'] = File.read('./app/assets/images/profile_partsnap.jpg')
  	return mail(to: email_address, subject: subject)
  end

  def blast_email_sender(addresses,subject,validate=true)
    addresses.each do |a|
      if !validate or User.can_use_email?(a)
        b = BlastMailer.blast_email(a,subject)
        b.deliver
      else
        puts "Not sending to #{a}"
      end
    end
  end

  def supplier_profile_reachout(supplier)
    @supplier = supplier
    @brand_name = brand_name
    @url_name_for_link = supplier_profile_path(supplier.name_for_link)
    @url_edit = edit_supplier_path(supplier.id)
    @asks_hash = supplier.asks_hash
    mail(to: supplier.email, subject:"Customers want to know more about #{supplier.name} on #{brand_name}!")
  end



end