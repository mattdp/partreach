# == Schema Information
#
# Table name: organizations
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#  people_are_called              :string(255)
#  external_bucket_name           :string(255)
#  external_bucket_env_var_access :string(255)
#  external_bucket_env_var_secret :string(255)
#  default_reminder_days          :integer          default(4)
#

class Organization < ActiveRecord::Base

  has_many :teams
  has_many :providers
  has_many :tags


  def create_synapse_pos_and_comments_from_tsv(url)
    
    output_string = ""    
    warning_prefix = "***** "

    tsv_data = open(url).read #http://ruby-doc.org/stdlib-2.0.0/libdoc/stringio/rdoc/StringIO.html

    CSV.parse(tsv_data, { :headers => true, :col_sep => "\t", :skip_blanks => true }) do |row|

      provider = nil  
      user = nil

      #test if row is supposed to be processed
      if !(row["Custom Part?"] == "TRUE" and row["Vendor already exists?"] == "TRUE")
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, not custom part or not vendor in DB\n"
        next
      end
      if row["Synapse PO number"].to_i == 0
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, no PO number present\n"
        next
      end
      if PurchaseOrder.where("id_in_purchasing_system = ?",row["Synapse PO number"].to_i).present?
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, PO #{row["Synapse PO number"]} already in system\n"
        next
      end

      #test if provider exists
      provider = Provider.safe_name_check(self.id,row["Vendor Name"])
      if !provider.present?
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, provider not found in this organization\n"
        next
      end

      #test if user exists
      if !(row["SB U ID"].present? and
        user = User.where("id = ?",row["SB U ID"].to_i) and
        user.present? and
        self.teams.include?(user[0].team))
          output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, user not found in this organization\n"
          next
      else
        user = user[0]
      end

      #create and test PO

      options = { description: row["Description"],
        project_name: row["Project Name"],
        id_in_purchasing_system: row["Synapse PO number"].to_i,
        price: row["Total Price"].to_f,
        quantity: row["Quantity"].to_i,
        issue_date: Date.parse(row["PO Issue Date"]),
        row_identifier: row['Start SB ID'],
        user: user}
      objects = provider.create_linked_po_and_comment!(options)
      output_string += objects[:output_string]
    end

    return output_string
  end

  #could do more joins to get users, leads, lead_contacts in, but that's premature optimization at this point
  def recent_activity(result_number = 10)

    range = (Date.today - 30.days)..(Date.today + 3.days) #fudge factor in case time zones ever weird

    #comments
    comments = Comment.joins(:provider).where("providers.organization_id = ?",self.id).
      where("overall_score > 0 OR payload IS NOT NULL").
      where("user_id IS NOT NULL").
      where(comments: {updated_at: range})
    comments = comments.select{|c| (!c.user.admin) and c.user.lead.present? and c.user.lead.lead_contact.present?}
    comments = comments.take(result_number)

    #new/updated providers
    provider_events = Event.joins("INNER JOIN providers ON events.target_model_id = providers.id").
      joins("INNER JOIN users ON events.model_id = users.id").
      where(events: {target_model: "Provider", model: "User", happening: ["created a provider","updated a provider"]}).
      where(providers: {created_at: range, organization_id: self.id}).
      where(users: {admin: false})
    provider_events = provider_events.select{|e| u = User.find(e.model_id) and u.lead.present? and u.lead.lead_contact.present?}
    provider_events = provider_events.take(result_number)

    return (comments + provider_events).sort_by(&:updated_at).reverse.take(result_number)

  end

  def analysis(start_date=Date.today-30.days,finish_date=Date.today)
    facts = {date_range: "#{start_date.to_s} to #{finish_date.to_s}"}

    facts[:filled_out_comments] = Comment.where("overall_score > 0 OR payload IS NOT NULL")
      .where("updated_at >= ? AND updated_at <= ?",start_date,finish_date)
      .select{|c| c.provider.organization == self}
      .count

    admin_ids = User.admins.map{|a| a.id}
    facts[:profile_views_non_admin] = Event.where("happening = 'loaded profile'")
      .where("created_at >= ? AND created_at <= ?",start_date,finish_date)
      .where.not(model_id: admin_ids)
      .count

    return facts
  end

  def healthy_users(date_within_month_to_check)
    users = self.users.select{|u| u.admin == false}
    healthy_user_count = 0
    number_of_events_to_count_a_day = 3
    number_of_days_for_a_healthy_user = 5

    users.each do |user|
      day_count = 0
      distribution = {}

      possible_events = Event.where("model = 'User' and model_id = ?",user.id)
      events = possible_events.select{|e| e.created_at.month == date_within_month_to_check.month}

      if events.present?
        events.each do |event|
          if distribution[event.created_at.day].present?
            distribution[event.created_at.day] << event
          else
            distribution[event.created_at.day] = [event]
          end
        end
        distribution.keys.each do |key|
          day_count += 1 if distribution[key].count >= number_of_events_to_count_a_day
        end
        healthy_user_count += 1 if day_count >= number_of_days_for_a_healthy_user
      end
    end

    return healthy_user_count

  end

  def tag_details
    tags = Tag.where("organization_id = ?", self.id)
    answer = {}
    tags.each do |tag|
      inserted = {}
      taggings = tag.taggings
      inserted[:num_providers] = tag.taggings.where("taggable_type = 'Provider'").count
      inserted[:num_providers] = nil if inserted[:num_providers] == 0
      pos = PurchaseOrder.joins("INNER JOIN taggings ON taggings.taggable_id = purchase_orders.id").
        where(taggings: {taggable_type: "PurchaseOrder", tag_id: tag.id}).
        where("issue_date IS NOT NULL").
        order(:issue_date)
      inserted[:num_pos] = (pos.present? ? pos.count : nil)
      if (inserted[:num_pos].present? and inserted[:num_pos] > 0)
        last_po = pos.last
        inserted[:last_po] = last_po
        inserted[:last_po_comment_id] = last_po.comment.id if last_po.comment.present?
        inserted[:last_po_provider] = last_po.provider
      end
      answer["#{tag.readable}"] = inserted
    end
    return answer
  end

  def colloquial_people_name
    returnee = nil
    self.people_are_called.present? ? returnee = self.people_are_called : returnee = self.name
    return returnee
  end

  def providers
    Provider.where(organization: self)
  end

  def providers_alpha_sort
    providers.sort_by { |p| p.name.downcase }
  end

  def provider_tags
    Tag.where(organization_id: self.id)
  end

  def providers_hash_by_tag
    hash = {}
    tags_with_providers = provider_tags.includes(:providers).references(:providers)
    tags_with_providers.sort_by {|tag| tag.readable.downcase }.each do |tag|
      # puts "tag.readable: #{tag.readable}"
      # tag.providers.sort_by {|provider| provider.name.downcase}.each do |provider|
      #   puts "provider.name: #{provider.name}"
      # end
      hash[tag] = tag.providers.sort_by {|provider| provider.name.downcase}
    end

    hash
  end

  def find_or_create_tag!(name,user)
    tag = self.find_existing_tag(name)
    unless tag.present?
      tag = self.create_tag(name,user)
    end
    return tag
  end

  def find_existing_tag(tag_name)
    tags = provider_tags
    found = tags.select do |tag|
      (tag.name_for_link == Tag.proper_name_for_link(tag_name)) || (tag.name == tag_name)
    end
    found.first
  end

  #user facing for org users
  def create_tag(tag_name, user)
    tag_name = tag_name[0..200]
    new_tag = Tag.create(
      name: tag_name, 
      readable: tag_name, 
      name_for_link: Tag.proper_name_for_link(tag_name), 
      tag_group: TagGroup.find_by_group_name("provider type"),
      organization: self)
    Event.add_event("User","#{user.id}" ,"added a new tag", "Tag", new_tag.id)

    new_tag
  end

  def users
    user_list = []
    if self.teams
      self.teams.each do |team|
        user_list.concat(team.users) if team.users.present?
      end
      return user_list
    else
      return nil
    end
  end

end
