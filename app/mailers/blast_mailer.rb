class BlastMailer < ActionMailer::Base
	default from: "noreply@supplybetter.com"
  include SessionsHelper

  def blast_email(email_address,subject)
    attachments.inline['pixil3d.jpg'] = File.read('./app/assets/images/profile_pixil3d.jpg')
    attachments.inline['partsnap.jpg'] = File.read('./app/assets/images/profile_partsnap.jpg')
  	return mail(to: email_address, subject: subject)
  end

  def blast_email_sender(addresses,subject)
    addresses.each do |a|
     b = BlastMailer.blast_email(a,subject)
     b.deliver
    end
  end

end