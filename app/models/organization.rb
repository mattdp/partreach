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

      #test if provider exists

      if !(row["Vendor Name"].present? and
        provider = Provider.where("name = ? and organization_id = ?",row["Vendor Name"],self.id) and
        provider.present?)
          output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, provider not found in this organization\n"
          next
      else
        provider = provider[0]
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

      po = PurchaseOrder.new({ provider: provider, description: row["Description"], project_name: row["Project Name"]})
      po.price = row["Total Price"].to_f if row["Total Price"].present?
      po.quantity = row["Quantity"].to_i if row["Quantity"].present?
      po.issue_date = Date.parse(row["PO Issue Date"]) if row["PO Issue Date"].present?

      if !po.save
        output_string += "#{warning_prefix}PO saving failure for row starting with SB ID #{row['Start SB ID']}. Skipping.\n"
        next
      end

      comment = Comment.new({user: user, provider: provider, comment_type: "purchase_order", purchase_order: po})
      if !comment.save
        output_string += "#{warning_prefix}WARNING: ORPHAN PO. Comment saving failure for row starting with SB ID #{row['Start SB ID']}.\n"
      else
        output_string += "Success. Comment #{comment.id} created from row with SB ID #{row['Start SB ID']}.\n"
      end

    end
    return output_string
  end

  #/Users/matt/Desktop/partreach-docs/mdp/151005-recent_comments.txt for thoughts on how to do right
  def recent_comments
    possibles = Comment.last(50)
    in_org_comments = possibles.select{|c| ((c.overall_score > 0 or c.payload.present?) and Provider.find(c.provider_id).organization_id == self.id)}
    in_org_comments = in_org_comments.select{|c| c.user.present? and c.user.lead.present? and c.user.lead.lead_contact.present?}
    return in_org_comments.sort_by{|c| c.created_at}.reverse.take(10)
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
