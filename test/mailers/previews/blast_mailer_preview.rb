class BlastMailerPreview < ActionMailer::Preview
  def c_reachout_1412_MiddleGround
    BlastMailer.c_reachout_1412_MiddleGround(sample_contact)
  end

  def c_reachout_1412_Casual
    BlastMailer.c_reachout_1412_Casual(sample_contact)
  end

  def c_reachout_1412_3dPrinting
    BlastMailer.c_reachout_1412_3dPrinting(sample_contact)
  end

  def c_reachout_1412_3dPrinting_no_first_name
    no_name_contact = sample_contact
    no_name_contact.first_name = nil;
    BlastMailer.c_reachout_1412_3dPrinting(no_name_contact)
  end

  private

  def sample_contact
    Contact.new(first_name: "Fred", email: "fred@test.com")
  end

end
