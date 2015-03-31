# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Organization < ActiveRecord::Base

  has_many :teams
  has_many :providers
  has_many :tags

  def providers
    Provider.where(organization: self)
  end

  def provider_tags
    tags
  end

  def providers_hash_by_tag
    hash = {}

    provider_tags.each do |tag|
      hash[tag] = providers.joins(:tags).where(tags: {id: tag.id}).order(:name)
    end

    hash
  end

  #user facing for org users
  def tag_creator(new_tag_names, user)
    new_tag_names.each do |tag_name|
      found = provider_tags.select do |tag|
        (tag.name_for_link == Tag.proper_name_for_link(tag_name)) || (tag.name == tag_name)
      end
      existing_tag = found.first

      if existing_tag
        Event.add_event("User","#{user.id}","attempted to add an existing tag","Tag", existing_tag.id)
      else
        new_tag = Tag.create(
          name: tag_name, 
          readable: tag_name, 
          name_for_link: Tag.proper_name_for_link(tag_name), 
          tag_group: TagGroup.find_by_group_name("provider type"),
          organization: self)
        Event.add_event("User","#{user.id}" ,"added a new tag", "Tag", new_tag.id)
      end
    end

    return true
  end

end
