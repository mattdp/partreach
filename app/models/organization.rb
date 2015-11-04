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
  has_many :projects
  has_many :purchase_orders, through: :providers
  has_many :taggings, :as => :taggable, :dependent => :destroy

  #tags -> which tags are in scope for the organization
  #taggings -> which tags are used for the index page side list

  SEARCH_STRING_SEPARATOR = "-"
  SEARCH_STRING_MODEL_CHARACTERS = 4
  SEARCH_STRING_MODEL_HASH = {"Provider"=>"p","Tag"=>"t"}

  #highly promiscous, will encode anything it can across orgs
  def self.encode_search_string(models,options=nil)
    return "" if models.blank?
    if options == "tag_ids" #when have a list of tag ids in string format
      strings = models.map{|m| "#{Organization::SEARCH_STRING_MODEL_HASH["Tag"]}#{m}"}
    else
      strings = models.map{|m| "#{Organization::SEARCH_STRING_MODEL_HASH[m.class.to_s]}#{m.id}"}
    end
    strings.join(Organization::SEARCH_STRING_SEPARATOR)
  end

  #tries to prevent errors and cross-org searching
  def decode_search_string(search_string)
    answer = []
    return answer if search_string.blank?

    decoder = Organization::SEARCH_STRING_MODEL_HASH.invert
    
    search_string.split(Organization::SEARCH_STRING_SEPARATOR).each do |ss|
      model_name = decoder[ss[0]]
      next if model_name.blank?
      id = ss[1..ss.length]
      next if id == 0
      answer << model_name.constantize.find(id)
    end
    return answer.select{|a| a.organization_id == self.id}
  end

  def common_search_tags(tags_with_provider_counts)
    minimum_tags_in_list = tags_with_provider_counts.size
    tags_returning = []
    taggings = self.taggings
    count = taggings.count

    tags_returning.concat(self.taggings.map{|tg| tg.tag}) if count > 0
    more_taggings_needed = minimum_tags_in_list - count
    if more_taggings_needed > 0 
      more_tag_ids = tags_with_provider_counts
        .take(more_taggings_needed)
        .map{|result_hash| result_hash["tag_id"].to_i}
      tags_returning.concat(Tag.find(more_tag_ids))
    end

    return tags_returning.sort_by{|t| t.readable}
  end

  #needs to actually work
  def user_behaviors(start_date=Date.parse("2015-04-04"),end_date=Date.today,allow_admins=false)
    behaviors = [] 
    users = self.users.reject{|u| u.admin} unless allow_admins
    users.each do |u|
      behaviors << u.behaviors(start_date,end_date)
    end
    return behaviors
  end

  def has_any_pos?
    return self.purchase_orders.present?
  end

  def last_provider_update
    Provider.where(organization_id: self.id).maximum(:updated_at)
  end

  def last_tag_update
    Tag.where(organization_id: self.id).maximum(:updated_at)
  end

  def projects_for_listing
    project_names = Project.where(organization_id: self.id).order(:name).map{|p| p.name}
    [Project.none_selected].concat(project_names)
  end

  def recent_activity(activity_types,recommendations=false,result_number=10)
    range = (Date.today - 30.days)..(Date.today + 3.days) #fudge factor in case time zones ever weird
    intermediate_results = []

    if "comments".in?(activity_types)
      comments = Comment.joins(:provider).where("providers.organization_id = ?",self.id).
        where("overall_score > 0 OR payload IS NOT NULL").
        where("user_id IS NOT NULL").
        where(comments: {updated_at: range}).
        order(updated_at: :desc)
      comments = comments.select{|c| (!c.user.admin) and c.user.lead.present? and c.user.lead.lead_contact.present?}
      if recommendations
        comments = comments.select{|c| c.has_recommendation?}
      else
        comments = comments.reject{|c| c.has_recommendation?}
      end
      intermediate_results += comments.take(result_number)
    end

    if "providers".in?(activity_types)
      updated_text = "updated a provider"
      provider_events = Event.joins("INNER JOIN providers ON events.target_model_id = providers.id").
        joins("INNER JOIN users ON events.model_id = users.id").
        where(events: {created_at: range, target_model: "Provider", model: "User", happening: ["created a provider",updated_text]}).
        where(providers: {organization_id: self.id}).
        where(users: {admin: false}).
        order(updated_at: :desc)
      #fudge factor for duplicate update events        
      provider_events = provider_events.
        select{|e| u = User.find(e.model_id) and u.lead.present? and u.lead.lead_contact.present?}.
        take(result_number*2)
      #no more than one event for updating the same provider; this should really be SQL
      i = 0
      while i < provider_events.length
        if provider_events[i].happening == updated_text
          provider_id = provider_events[i].target_model_id
          post_i = provider_events[i+1...provider_events.length]
          post_i = [] if post_i.blank?
          up_to_i = provider_events[0..i]
          provider_events = up_to_i + 
            post_i.reject{|event| 
              event.happening == updated_text and 
              event.target_model_id == provider_id
            }
        end
        i += 1
      end
      intermediate_results += provider_events.take(result_number)
    end

    return intermediate_results.sort_by(&:updated_at).reverse.take(result_number)
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
      .select{|e| e.model == "User" and User.find(e.model_id).present? and User.find(e.model_id).organization == self}
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

  def tag_details(model)
    tags = Tag.where("organization_id = ?", self.id)
    answer = {}
    tags.each do |tag|
      inserted = {}
      provider_taggings = tag.taggings.where("taggable_type = 'Provider'")
      inserted[:tag_id] = tag.id
      inserted[:num_providers] = provider_taggings.count
      if inserted[:num_providers] == 0
        inserted[:num_providers] = nil
        next
      end
      if model == :purchase_order
        models = PurchaseOrder.joins("INNER JOIN taggings ON taggings.taggable_id = purchase_orders.id").
          where(taggings: {taggable_type: "PurchaseOrder", tag_id: tag.id}).
          where("issue_date IS NOT NULL").
          order(issue_date: :desc)
        inserted[:num_models] = (models.present? ? models.count : nil)
        if (inserted[:num_models].present? and inserted[:num_models] > 0)
          inserted[:last_model] = models.first
          inserted[:last_po_comment_id] = inserted[:last_model].comment.id if inserted[:last_model].comment.present?
          inserted[:last_provider] = inserted[:last_model].provider
        end
      elsif model == :comment
        provider_ids = provider_taggings.map{|tagging| tagging.taggable_id}
        inserted[:last_model] = Comment.where(provider_id: provider_ids).order(updated_at: :desc).first
        inserted[:last_provider] = inserted[:last_model].provider if inserted[:last_model].present?
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

  def tags_with_provider_counts
    organization = self # for easy pasting debug

    ActiveRecord::Base.connection.exec_query(" 
    SELECT tags_and_taggings.tag_readable AS tag_readable, tags_and_taggings.tag_id AS tag_id, COUNT(providers.id) AS providers_count
    FROM (
      SELECT tags.readable AS tag_readable, tags.id AS tag_id, taggings.taggable_id AS taggable_id
      FROM tags INNER JOIN taggings ON tags.id=taggings.tag_id
      WHERE tags.organization_id=#{organization.id} 
      AND taggings.taggable_type='Provider'
      ) AS tags_and_taggings INNER JOIN providers ON tags_and_taggings.taggable_id=providers.id
    GROUP BY tags_and_taggings.tag_readable, tags_and_taggings.tag_id
    ORDER BY COUNT(providers.id) DESC, lower(tags_and_taggings.tag_readable)
    ")
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
