class BlastMailer < ActionMailer::Base
	default from: "noreply@supplybetter.com"
  include SessionsHelper

  def blast_email(email_address,subject,content_name)
  	@content = content_holder(content_name)
    attachments.inline['example_1.png'] = File.read('./app/assets/images/matt_headshot.png')
    attachments.inline['example_2.png'] = File.read('./app/assets/images/matt_headshot.png')
  	mail(to: email_address, subject: subject)
  end

  def content_holder(content_name)
  	case content_name
  	when "us_supplier_profiles"
  		return 
  	else
  		return false
  	end
  end

end