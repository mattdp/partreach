###################################################################################
unless Rails.env.production? # don't allow this to run in production environment!!!
###################################################################################

  desc 'replace certain fields with fake data'
  task :obfuscate_data => :environment do
    obfuscate_team_user
    obfuscate_organization
    obfuscate_team
    obfuscate_provider
    obfuscate_comment
  end

  def obfuscate_team_user
    User.where.not(team: nil).each do |user|
      begin
        user.password = "changemeplease"
        user.password_confirmation = "changemeplease"
        user.save!

        contact = user.lead.lead_contact
        contact.first_name =        Faker::Name.first_name
        contact.last_name =         Faker::Name.last_name
        contact.name =              "#{contact.first_name} #{contact.last_name}"
        contact.phone =             Faker::PhoneNumber.phone_number
        contact.email =             Faker::Internet.safe_email(contact.first_name)
        # contact.method
        contact.notes =             nil
        # contact.type
        # contact.contactable_id
        # contact.contactable_type
        contact.title =             Faker::Name.title
        contact.company =           Faker::Company.name
        contact.linkedin_url =      nil
        # contact.email_valid
        # contact.email_subscribed
        contact.cc_emails =         nil
        contact.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update user #{team.id}: #{e.message}"
      end
    end
  end

  def obfuscate_organization
    Organization.all.each do |organization|
      begin
        organization.name = Faker::App.name
        organization.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update Organization #{organization.id}: #{e.message}"
      end
    end
  end

  def obfuscate_team
    Team.all.each do |team|
      begin
        team.name = Faker::App.name
        team.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update Team #{team.id}: #{e.message}"
      end
    end
  end

  def obfuscate_provider
    Provider.all.each do |provider|
      begin
        provider.name =            Faker::Company.name
        provider.name_for_link =   Provider.proper_name_for_link(provider.name)
        provider.url_main =        Faker::Internet.url
        provider.source =          "manual"
        provider.contact_name =    Faker::Name.name
        provider.contact_qq =      Faker::Number.number(10)
        provider.contact_wechat =  Faker::Internet.user_name(provider.contact_name)
        provider.contact_phone =   Faker::PhoneNumber.phone_number
        provider.contact_email =   Faker::Internet.safe_email(provider.contact_name)
        provider.contact_role =    Faker::Name.title
        # provider.verified
        provider.city =            Faker::Address.city
        provider.address =         "#{Faker::Address.street_address}, #{provider.city}"
        # provider.id_within_source
        provider.contact_skype =   Faker::Lorem.word
        provider.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update Provider #{provider.id}: #{e.message}"
      end
    end
  end

  def obfuscate_comment
    Comment.all.each do |comment|
      begin
        # comment.user_id
        # comment.provider_id
        # comment.comment_type
        comment.payload =       Faker::Lorem.sentences(5).join(" ")
        # comment.overall_score
        comment.title =         Faker::Lorem.sentence
        comment.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update Comments #{team.id}: #{e.message}"
      end
    end
  end

end
