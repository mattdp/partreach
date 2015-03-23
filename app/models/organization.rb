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
    tags.by_taggable_type('Provider')
  end

  def providers_hash_by_tag
    hash = {}

    provider_tags.each do |tag|
      hash[tag] = providers.joins(:tags).where(tags: {id: tag.id}).order(:name)
    end

    hash
  end

end
