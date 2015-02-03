# == Schema Information
#
# Table name: providers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  url_main      :string(255)
#  source        :string(255)      default("manual")
#  name_for_link :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Provider < ActiveRecord::Base

  before_save :prepend_http_to_url

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}
  validates :url_main, uniqueness: {case_sensitive: false}, allow_nil: true

  def self.proper_name_for_link(name)
    return name.downcase.gsub(/\W+/, "")
  end

  def prepend_http_to_url
    if self.url_main
      self.url_main = /^http/.match(self.url_main) ? self.url_main : "http://#{self.url_main}"
    end
  end

  #TO DO

  def add_flag(flag_name)
  end

  def remove_flag(flag_name)
  end

  def has_flag?(flag_name)
  end

end
