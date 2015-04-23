# encoding: utf-8

module DataEntry

  require 'csv'

  ZIP_COUNTRY = 0
  ZIP_POSTAL = 1
  ZIP_LOCATION_NAME = 2

  #for the canonical zip code database
  def zipreader(url)
    CSV.new(open(url), {:col_sep => "\t"}).each do |row|
      l = Location.new({:country => row[ZIP_COUNTRY],
                        :zip => row[ZIP_POSTAL],
                        :location_name => row[ZIP_LOCATION_NAME]
                      })
      l.save if Location.where('zip = ?',l.zip) == []
    end
    return "Load attempted"
  end

  def march2014_linkedin_import(location)

    cols = {
      first_name: 1,
      last_name: 2,
      location: 3,
      company: 4,
      title: 5,
      linkedin_url: 6,
      email: 7
    }
    counter = 0

    CSV.new(open(location)).each do |row|
      counter += 1
      indicator = row[cols[:linkedin_url]]
      next unless (indicator.present? and counter > 1)

      if email = row[cols[:email]] and LeadContact.find_by_email(email)
        puts "Lead with this email already exists, skipping. (#{email})"
      elsif linkedin_url = row[cols[:linkedin_url]] and LeadContact.find_by_linkedin_url(linkedin_url)
        puts "Lead with this LinkedIn URL already exists, skipping. (#{linkedin_url})"
      else
        
        create_hash = {}
        attributes = [:first_name, :last_name, :company, :title, :email, :linkedin_url]
        attributes.each do |attribute|
          create_hash[attribute] = row[cols[attribute]]
        end
        create_hash[:notes] = "From task - Location: #{row[cols[:location]]}"
        create_hash[:contactable_type] = "Lead"

        begin
          Lead.transaction do
            lead = Lead.create!({source: "LinkedIn task 3/31"})
            create_hash[:contactable_id] = lead.id
            LeadContact.create!(create_hash)
            puts "Lead for #{indicator} imported correctly."
          end
        rescue
          puts "Error importing lead for #{indicator}."
        end

      end
    end
    return "Upload attempted."
  end

  MEETUP_NAME = 1
  MEETUP_FIRSTNAME = 2
  MEETUP_LASTNAME = 3
  MEETUP_LOCATION = 4
  MEETUP_INTRO = 5
  MEETUP_INTERESTED = 6
  MEETUP_LINKEDIN = 7
  MEETUP_EMAIL = 9

  def meetup_task_import(location)
    counter = 0
    CSV.new(open(location)).each do |row|
      counter += 1
      last_name = row[MEETUP_LASTNAME]
      next unless (last_name.present? and counter > 1)
      if lead = Lead.create({source: "Meetup task 2/14"}) and LeadContact.create({name: row[MEETUP_NAME], \
          first_name: row[MEETUP_FIRSTNAME], last_name: last_name, linkedin_url: row[MEETUP_LINKEDIN], \
          notes: "From task - Location: #{row[MEETUP_LOCATION]} | Intro: #{row[MEETUP_INTRO]} | Interested in: #{row[MEETUP_INTERESTED]}", \
          email: row[MEETUP_EMAIL], contactable_id: lead.id, contactable_type: "Lead"})
        puts "Lead for #{last_name} imported correctly."
      else
        puts "Error importing lead for #{last_name}"
      end
    end
    return "Meetup lead upload attempted"
  end

  # CURRENT USE - csv_to_hashes(filepath) on local machine, result = <output> on heroku,
  # call hashes_to_saved_changes(result) on heroku

  def usage_counter
    answer = "Num_Ord\tNum_Bid\tUsr_id\tUsr_email\n"
    total_order_counter = total_bid_counter = 0
    User.find_each do |u|
      order_counter = 0
      bid_counter = 0 # not all users have orders
      u.orders.each do |o|
        order_counter += 1
        bid_counter = 0
        o.dialogues.each do |d|
          bid_counter += 1 if (d.response_received and !d.total_cost.nil? and d.total_cost > 0)
        end
      end
      answer += "#{order_counter}\t#{bid_counter}\t"
      answer += "#{u.id}\t#{u.email}\n"
      total_bid_counter += bid_counter
      total_order_counter += order_counter
    end
    answer += "------\n#{total_order_counter}\t#{total_bid_counter}\t#{User.all.count}\tTotals\n"
    return answer
  end

  def list_dialogues(order_id)
    answer = "Ord_id\tDia_id\tSupplier\n"
    Dialogue.find_each do |d|
      if d.order_id == order_id
        answer += "#{order_id}\t#{d.id}\t#{Supplier.find(d.supplier_id).name}\n"
      end
    end
    return answer
  end

  STREAK_NAME = 0
  STREAK_NOTES = 1
  STREAK_EMAIL = 2

  def streak_buyer_import(location)
    counter = 0
    CSV.new(open(location)).each do |row|
      name = row[STREAK_NAME]
      next if (!name.present? or name == "Name")
      if lead = Lead.create({source: "Streak"}) and LeadContact.create({name: name, notes: row[STREAK_NOTES], \
                email: row[STREAK_EMAIL], contactable_id: lead.id, contactable_type: "Lead"})
        puts "Lead for #{name} imported correctly."
      else
        puts "Error importing lead for #{name}"
      end
      counter += 1
    end
    return "Streak buyer upload attempted"
  end

  PRINTER_MANUFACTURER = 0
  PRINTER_MODEL = 1
  PRINTER_URL = 2

  def printer_import(location)
    counter = 0
    CSV.new(open(location)).each do |row|
      counter += 1
      next unless counter > 1
      if (manufacturer = Manufacturer.create_or_reference_manufacturer(name: row[PRINTER_MANUFACTURER]) and \
          machine = Machine.create_or_reference_machine(name: row[PRINTER_MODEL], manufacturer_id: manufacturer.id, ))
        machine.create_or_change_external(row[PRINTER_URL])
        puts "#{row[PRINTER_MANUFACTURER]} #{row[PRINTER_MODEL]} imported correctly."
      else
        puts "Error importing machcine for #{row[PRINTER_MANUFACTURER]} #{row[PRINTER_MODEL]}"
      end
    end
    return "Machine upload attempted"
  end

  TAG_NAME = 0
  TAG_FAMILY = 1
  TAG_READABLE = 2
  TAG_NOTE = 3
  TAG_EXCLUSIVE = 4
  TAG_VISIBLE = 5

  def csv_to_tags_row_helper(row, counter)        
    puts "first" if counter == 0
    n = row[TAG_NAME]
    if !n.nil? and n.length > 0 and counter > 0
      t = Tag.predefined(n)
      t = Tag.new if t.nil?
      t.name = n
      t.family = row[TAG_FAMILY]
      t.readable = row[TAG_READABLE]
      t.name_for_link = Tag.proper_name_for_link(t.readable)
      t.note = row[TAG_NOTE] if !row[TAG_NOTE].nil? and row[TAG_NOTE].length > 0
      t.exclusive = row[TAG_EXCLUSIVE] if !row[TAG_EXCLUSIVE].nil? and row[TAG_EXCLUSIVE].length > 0
      t.visible = row[TAG_VISIBLE] if !row[TAG_VISIBLE].nil? and row[TAG_VISIBLE].length > 0
      if t.save
        puts "#{t.name} saved."
      else
        puts "Error saving #{t.name}."
      end
    end
  end

  def hashes_to_saved_changes(hashes)
    hashes.each do |h|
      #use ID to find dialogue
      d = Dialogue.find(h[:id])
      #remove ID from hash
      h.delete(:id)

      #if it's an all-string hash, set the data types correctly
      h.keys.each do |k|

        k = "" if k.nil?

        if [:process_cost, :shipping_cost, :total_cost].include? k
          h[k] = BigDecimal.new(h[k])
        elsif [:id].include? k
          h[k] = h[k].to_i
        end
      end

      #update attributes (check in testing if mass assignment works)
      d.update_attributes(h)
    end
  end

end