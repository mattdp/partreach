module TagManipulation

  def update_tags(submitted_tag_ids,allow_removal=true)
    saved_ok = true
    
    if(submitted_tag_ids and submitted_tag_ids.size > 0)

      current_tag_ids = self.tags.map{|t| "#{t.id}"}
      add_tag_ids = []
      remove_tag_ids = []

      submitted_tag_ids.map{|t| add_tag_ids << t if !t.in?(current_tag_ids)}
      current_tag_ids.map{|t| remove_tag_ids << t if !t.in?(submitted_tag_ids)}

      if add_tag_ids.size > 0
        add_tag_ids.each do |id|
          saved_ok = false unless self.add_tag(id)
        end
      end

      if (remove_tag_ids.size > 0 and allow_removal)
        remove_tag_ids.each do |id|
          saved_ok = false unless self.remove_tags(id)
        end
      end
    end

    return saved_ok
  end

  def has_tag?(tag_id)
    tags = taggings.map {|tg| tg.tag_id}
    tags.include? tag_id
  end

  #NEED WORK - DOESN'T CHECK IF IN ORG
  def add_tag(tag_id)
    tag = Tag.find_by_id(tag_id)
    return false if tags.include?(tag)
    tags << tag
    return true
  end

  def remove_tags(tag_id)
    self.tags.destroy(tag_id)
  end  

end