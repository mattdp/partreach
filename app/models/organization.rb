# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  people_are_called :string(255)
#

class Organization < ActiveRecord::Base

  has_many :teams
  has_many :providers
  has_many :tags

  #/Users/matt/Desktop/partreach-docs/mdp/151005-recent_comments.txt for thoughts on how to do right
  def recent_comments
    possibles = Comment.last(50)
    in_org_comments = possibles.select{|c| (c.payload.present? and Provider.find(c.provider_id).organization_id == self.id)}
    return in_org_comments.sort_by{|c| c.created_at}.reverse.take(10)
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

end
