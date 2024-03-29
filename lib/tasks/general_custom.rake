require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

desc 'setup root of tag hierarchy'
task tag_web_setup: :environment do
  Organization.find_each do |o|
    abort = false
    tag_names = ["root","processes","services","products","materials"]
    tag_names.each do |tag_name|
      if o.find_existing_tag(tag_name).present?
        puts "Organization #{o.id} has some root tags already, investigate."
        abort = true
      end
    end
    if !abort
      root_id = nil
      child_id = TagRelationshipType.find_by_name("child").id
      tag_names.each do |tag_name|
        t = o.create_tag(tag_name,User.first)
        if tag_name == "root"
          root_id = t.id 
        else
          TagRelationship.create(source_tag_id: t.id,
            related_tag_id: root_id,
            tag_relationship_type_id: child_id)
        end
      end
    end
  end
end

desc 'set up tag relationships if they are not found'
task tag_relationship_setup: :environment do
  required = [
    ["is a child of","child"],
    ["is less commonly used than","worse_synonym"],
    ["often is related to","calls_for"]
  ]
  tg = TagGroup.where(group_name: "provider type")
  if !tg.present?
    puts "Need a provider type group. Is there something wrong here?"
  else
    required.each do |long,short|
      trt = TagRelationshipType.where(name: short)
      if !trt.present?
        TagRelationshipType.create(name: short, description: long, 
          source_group_id: tg[0].id, related_group_id: tg[0].id)
      end
    end
  end
end

desc 'make sure no organizations are tied into tags that they dont use'
task tag_cleaner: :environment do
  output_string = ""
  taggings = Tagging.where(taggable_type: ["Provider","PurchaseOrder"])
  taggings.each do |tagging|
    possible_tag = Tag.where(id: tagging.id)

    if tagging.taggable_type == "Provider"
      possible_provider = Provider.where(id: tagging.taggable_id)
    elsif tagging.taggable_type == "PurchaseOrder"
      possible_provider = Provider.where(id: PurchaseOrder.find(tagging.taggable_id).id)
    else
      possible_provider = nil
    end

    if (possible_tag.present? and possible_provider.present?)
      tag = possible_tag[0]
      provider = possible_provider[0]
      if provider.organization_id != tag.organization_id
        output_string += "Incorrect tagging found - provider #{provider.name} 
          in organization #{provider.organization.id} 
          had tag #{tag.name}, which belongs to organzation
          #{tag.organization_id}..."
        correct_tag = provider.organization.find_or_create_tag!(tag.name,User.first)
        tagging.tag = correct_tag
        if tagging.save        
          output_string += "Repaired\n"
        else
          output_string += "ERROR - repair failed.\n"
        end
      end
    end
  end
  puts output_string
end


desc 'modify supplier tags based on their history in the app'
task :supplier_tagger => :environment do
  
  #toggle recent vs all for comments

  #dialogues = Dialogue.all
  dialogues = Dialogue.where("updated_at > ?",Date.today-7.days)
  
  dialogues.find_each do |d|
    d.autotagger
  end
end

desc 'crawl a set of suppliers in the background'
task :crawler_dispatcher => :environment do
  states = Geography.all_us_states
  scale_workers(1)
  states.each do |state|
    short_name = state.short_name
    next if (short_name == "NY" or short_name == "NH" or short_name == "CA")

    geo_id = state.id
    tag_id = Tag.predefined("3d_printing").id

    filter = Filter.where("has_tag_id = ? AND geography_id = ?",tag_id,geo_id).first #assumed this is a state-level filter
    suppliers = Supplier.quantity_by_tag_id("all",Tag.find(filter.has_tag_id),filter.geography.geography.short_name,filter.geography.short_name)
    
    Crawler.delay.crawl_master(suppliers)
  end
end

desc 'send daily update email'
task :daily_internal_update => :environment do 
  yesterday = Date.today-1
  Event.daily_update_2015(yesterday)
end

desc 'update all suppliers points'
task :update_all_suppliers_points => :environment do
  point_structure = Supplier.get_in_use_point_structure
  Supplier.find_each do |s|
    if s.existence_questionable?
      s.points = -1
    else
      s.points = s.point_scoring(point_structure)
    end
    s.save(validate: false)
  end
end

desc 'expose all US suppliers with certain tag constraints. not in scheduler.'
task :us_suppliers_public => :environment do
  haves = ["3d_printing"]
  have_nots = ["datadump"] 
  Supplier.find_each do |s|
    s.profile_visible = false
    #practicing blocks; yes, this should be more lines. meant to test if 'have' tags are on supplier and 'have_nots' aren't.
    if s.address and s.address.country.short_name == "US" and !( 
       haves.map{ |h| s.has_tag?(Tag.predefined(h).id) }.include?(false) or
       have_nots.map{ |h| s.has_tag?(Tag.predefined(h).id) }.include?(true)
       )
      s.profile_visible = true
    end
    s.save
  end
end

#should refactor so has set of primary tag to be invoked if a secondary is present
desc 'add dependant tags to all suppliers automatically'
task :tag_tree => :environment do

  automatics = {
    "3d_printing" => ["SLS","FDM","SLA","Polyjet","ZPrinter","metal_printing","DMLS","FFF"],
    "cnc_machining" => ["5_axis_machining"],
    "metal_printing" => ["DMLS"]
  }

  automatics.keys.each do |k|
    primary = Tag.predefined(k).id
    secondaries = automatics[k].map { |t| t = Tag.predefined(t).id }

    Supplier.find_each do |s|
      if !s.has_tag?(primary) #ok that this falses a lot, though could be more efficient
        s.tags.each do |t|
          s.add_tag(primary) if secondaries.include? t.id
        end
      end
    end

  end

end

desc 'Setup URL names for suppliers and tags'
task :supplier_url_creation => :environment do
  Supplier.find_each do |s|
    s.name_for_link = Supplier.proper_name_for_link(s.name)
    s.save
  end
  Tag.find_each do |t|
    t.name_for_link = Tag.proper_name_for_link(t.readable)
    t.save
  end
end

desc 'Best-guess take on whether requests for supplier data were made by humans or crawlers'
task :ask_screener => :environment do
  reach = 1 #lowered to be less forgiving
  range_in_seconds = 7 
  Ask.find_each do |a|
    if a.real.nil? #don't reprocess already-screened asks
      past = Ask.where("id = ?",a.id - reach)
      future = Ask.where("id = ?",a.id + reach)
      if !(past == [] or future == [])
        current_time = a.created_at
        past_gap = (past[0].created_at - current_time).abs
        future_gap = (future[0].created_at - current_time).abs
        if past_gap < range_in_seconds or future_gap < range_in_seconds
          a.real = false
        else
          a.real = true
        end
        a.save
      end
    end
  end
end

desc 'paragraphify supplier descriptions outside <p> tags'
task :paragraphify_suppliers => :environment do
  Supplier.find_each do |supplier|
    if supplier.description.present? and !supplier.description.include?("<")
      supplier.description = "<p>#{supplier.description}</p>"
      supplier.save validate: false
    end
  end
end