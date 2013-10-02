# == Schema Information
#
# Table name: reviews
#
#  id              :integer          not null, primary key
#  company         :string(255)
#  process         :string(255)
#  part_type       :string(255)
#  would_recommend :boolean
#  quality         :integer
#  adaptability    :integer
#  delivery        :integer
#  did_well        :text
#  did_badly       :text
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  displayable     :boolean
#  supplier_id     :integer
#

class Review < ActiveRecord::Base

  belongs_to :user
  belongs_to :supplier

  def self.quantity_for_examination(quantity)
    quantity = Review.all.count if quantity == "all"
    reviews = Review.where("displayable IS NULL").take(quantity)
    return reviews
  end 

  def self.pending_examination
    return Review.where("displayable IS NULL").count
  end

  #validates :company, presence: true, length: {minimum: 1}
  #validates :process, presence: true, length: {minimum: 1}
  #validates :part_type, presence: true, length: {minimum: 1}
  #validates :would_recommend, presence: true

  #validates :quality, presence: true, numericality: {greater_than: 0, less_than: 6}
  #validates :adaptability, presence: true, numericality: {greater_than: 0, less_than: 6}
  #validates :delivery, presence: true, numericality: {greater_than: 0, less_than: 6}

  #validates :did_well, presence: true, length: {minimum: 50}
  #validates :did_badly, presence: true, length: {minimum: 50}
end
