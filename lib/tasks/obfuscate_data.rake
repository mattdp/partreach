###################################################################################
unless Rails.env.production? # don't allow this to run in production environment!!!
###################################################################################

  desc 'replace certain fields with fake data'
  task :obfuscate_data => :environment do
    obfuscate_team_user
    obfuscate_organization
    obfuscate_team
    obfuscate_provider
    obfuscate_address
    obfuscate_comment
    obfuscate_purchase_order
  end

  def obfuscate_team_user
    User.where.not(team: nil).where(admin: false).each do |user|
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
        puts "***** ERROR attempting to update User #{obfuscate_team_user.id}: #{e.message}"
      end
    end
  end

  def obfuscate_organization
    Organization.all.each do |organization|
      begin
        organization.name = Faker::App.name
        organization.people_are_called = "your colleagues"
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
    # delete all existing external image links
    External.where(consumer_type: 'Provider').delete_all

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
        provider.location_string = "#{Faker::Address.street_address}, #{provider.city}"
        # provider.id_within_source
        provider.contact_skype =   Faker::Lorem.word
        provider.organization_private_notes = Faker::Lorem.sentences(5).join(" ")
        provider.external_notes = Faker::Lorem.sentences(2).join(" ")
        provider.supplybetter_private_notes = nil

        #add some external images
        external = External.new(
          url: 'https://s3.amazonaws.com/dev-clientfiles-test/IMG_4503-midsize.JPG',
          remote_file_name: 'IMG_4503-midsize.JPG' )
        provider.externals << external

        external = External.new(
          url: 'https://s3.amazonaws.com/dev-clientfiles-test/IMG_4443-midsize.JPG',
          remote_file_name: 'IMG_4443-midsize.JPG' )
        provider.externals << external

        external = External.new(
          url: 'https://s3.amazonaws.com/dev-clientfiles-test/IMG_4446-midsize.JPG',
          remote_file_name: 'IMG_4446-midsize.JPG' )
        provider.externals << external

        external = External.new(
          url: 'https://s3.amazonaws.com/dev-clientfiles-test/IMG_4451-midsize.JPG',
          remote_file_name: 'IMG_4451-midsize.JPG' )
        provider.externals << external

        provider.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update Provider #{provider.id}: #{e.message}"
      end
    end
  end

  def obfuscate_address
    Address.where(place_type: 'Provider').each do |address|
      begin
        address.city = Faker::Address.city
        address.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update Address #{address.id}: #{e.message}"
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
        puts "***** ERROR attempting to update Comment #{comment.id}: #{e.message}"
      end
    end
  end

  def obfuscate_purchase_order
    PurchaseOrder.all.each do |purchase_order|
      begin
        purchase_order.project_name =  Faker::Lorem.words(2).join(" ")
        purchase_order.description =   Faker::Lorem.sentences(2).join(" ")
        purchase_order.save!
      rescue ActiveRecord::ActiveRecordError => e
        puts "***** ERROR attempting to update PurchaseOrder #{purchase_order.id}: #{e.message}"
      end
    end
  end

end
