# == Schema Information
#
# Table name: words
#
#  id            :integer          not null, primary key
#  shortform     :string(255)
#  longform      :string(255)
#  name_for_link :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  family        :string(255)
#

class Word < ActiveRecord::Base

	validates :shortform, presence: true, uniqueness: {case_sensitive: false}
	validates :longform, presence: true, uniqueness: {case_sensitive: false}
	validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}
	validates :family, presence: true

	#array = [[shortform,longform,family],[shortform,longform,family],...]
	def self.loader (array)
		array.each do |a|
			w = Word.new({shortform: a[0], longform: a[1], family: a[2], \
				name_for_link: Word.proper_name_for_link(a[1])})
			puts "Error saving ['#{a[0]}', '#{a[1]}']" unless w.save
		end
		return true
	end

	def self.proper_name_for_link(input)
		return Supplier.proper_name_for_link(input)
	end

  def self.is_in_family?(text,family,symbol)
  	return false if text.nil?
  	word = Word.locate(text,symbol)
  	return (word and word.family == family)
  end

  def self.locate(text,symbol)
  	Word.all.detect {|word| word.send(symbol) == text}
  end

  def self.transform(from_symbol,input,to_symbol)
    word = Word.locate(input,from_symbol)
    return nil if word.nil?
    return word.send(to_symbol)
  end

  def self.all_us_states_shortform
  	Word.where("family = 'us_states'").map{|w| w.shortform}
  end

	#to delete after initial load
	def self.initial_information

		countries = 
		  [
		    ["US","United States","countries"]
		  ]
	    
	  us_states =
		  [ 
		    ["AL","Alabama","us_states"],
		    ["AK","Alaska","us_states"],
		    ["AZ","Arizona","us_states"],
		    ["AR","Arkansas","us_states"],
		    ["CA","California","us_states"],
		    ["CO","Colorado","us_states"],
		    ["CT","Connecticut","us_states"],
		    ["DE","Delaware","us_states"],
		    ["DC","District of Columbia","us_states"],
		    ["FL","Florida","us_states"],
		    ["GA","Georgia","us_states"],
		    ["HI","Hawaii","us_states"],
		    ["ID","Idaho","us_states"],
		    ["IL","Illinois","us_states"],
		    ["IN","Indiana","us_states"],
		    ["IA","Iowa","us_states"],
		    ["KS","Kansas","us_states"],
		    ["KY","Kentucky","us_states"],
		    ["LA","Louisiana","us_states"],
		    ["ME","Maine","us_states"],
		    ["MD","Maryland","us_states"],
		    ["MA","Massachusetts","us_states"],
		    ["MI","Michigan","us_states"],
		    ["MN","Minnesota","us_states"],
		    ["MS","Mississippi","us_states"],
		    ["MO","Missouri","us_states"],
		    ["MT","Montana","us_states"],
		    ["NE","Nebraska","us_states"],
		    ["NV","Nevada","us_states"],
		    ["NH","New Hampshire","us_states"],
		    ["NJ","New Jersey","us_states"],
		    ["NM","New Mexico","us_states"],
		    ["NY","New York","us_states"],
		    ["NC","North Carolina","us_states"],
		    ["ND","North Dakota","us_states"],
		    ["OH","Ohio","us_states"],
		    ["OK","Oklahoma","us_states"],
		    ["OR","Oregon","us_states"],
		    ["PA","Pennsylvania","us_states"],
		    ["RI","Rhode Island","us_states"],
		    ["SC","South Carolina","us_states"],
		    ["SD","South Dakota","us_states"],
		    ["TN","Tennessee","us_states"],
		    ["TX","Texas","us_states"],
		    ["UT","Utah","us_states"],
		    ["VT","Vermont","us_states"],
		    ["VA","Virginia","us_states"],
		    ["WA","Washington","us_states"],
		    ["WV","West Virginia","us_states"],
		    ["WI","Wisconsin","us_states"],
		    ["WY","Wyoming","us_states"]
		  ]

		Word.loader(countries)
		Word.loader(us_states)
  
	end

end
