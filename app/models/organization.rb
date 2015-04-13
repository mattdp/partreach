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

    provider_tags.sort_by { |t| t.readable}.each do |tag|
      hash[tag] = providers.joins(:tags).where(tags: {id: tag.id}).order(:name)
    end

    hash
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
    new_tag = Tag.create(
      name: tag_name, 
      readable: tag_name, 
      name_for_link: Tag.proper_name_for_link(tag_name), 
      tag_group: TagGroup.find_by_group_name("provider type"),
      organization: self)
    Event.add_event("User","#{user.id}" ,"added a new tag", "Tag", new_tag.id)

    new_tag
  end

end
