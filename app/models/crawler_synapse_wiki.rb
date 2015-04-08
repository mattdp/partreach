class CrawlerSynapseWiki
  require 'mechanize'

  #goal of this method is to get the source file for every vendor page in the wiki
  def self.get_source_files
    #heavily drawing upon http://docs.seattlerb.org/mechanize/EXAMPLES_rdoc.html
    mech = Mechanize.new
    
    # ISSUE with certification + site not letting me in
    # possible help http://stackoverflow.com/questions/8567973/why-does-accessing-a-ssl-site-with-mechanize-on-windows-fail-but-on-mac-work
    # mech.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    login_page = mech.get('https://sso.synapse.com/login?service=https%3A%2F%2Fwiki.synapse.com%2Fhomepage.action')    

    next_page = login_page.form_with(id: "login-form") do |f|
      f.username = "supply.better"
      f.password = "w!ndyNail22"
    end.click_button

    return next_page
  end

  #goal of this method is to take an individual source file and create the correct information in synapse's org
  #using a bunch of iteration and checking instead of regex, since that's not available via xpath in Rails
  def self.upload_wiki_pages

    #missing
    # => synapsers that used this one
    # => company descriptions
    # => logging of when non compete used
    # => notes at bottom

    example_urls = ["https://s3.amazonaws.com/temp_for_uploading/1.html",
      "https://s3.amazonaws.com/temp_for_uploading/2.html",
      "https://s3.amazonaws.com/temp_for_uploading/3.html",
      "https://s3.amazonaws.com/temp_for_uploading/4.html"]

    urls = example_urls #so everything else works once we have the real ones
    carrier = []

    urls.each do |url|
      page = Nokogiri::HTML(open(url))
      div_wiki_content = page.css('#content > div.wiki-content')
      div_wiki_content_headers = div_wiki_content.css("h2")
      warnings = []

      #who updated, when was last update
      update = page.css("li.page-metadata-modification-info").text.strip

      #bullet points under capabilities, to make into tags
      tags_from_capabilities = [] 
      capability_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("Capabilities")}.first
      capability_list = capability_header.next_element
      capability_list.css("li").each do |li|
        tags_from_capabilities << li.text.strip if li.text.present?
      end
      warnings >> "No tags from capabilties" if tags_from_capabilities.empty? 
      
      #flag if noncompete content, handle manually
      nocompete_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("DoNotCompeteWith")}.first
      warnings >> "Noncompete text present" if (nocompete_header.present? and nocompete_header.next_element.text.present? and nocompete_header.next_element.text != "&nbsp")

      #need to check for longform content
      synopsis_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("CompanySynopsis")}.first
      synopsis_text = synopsis_header.next_element.text.strip
      (synopsis_text.present? and synopsis_text != "&nbsp") ? synopsis = synopsis_text : synopsis = nil

      focus_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("CoreFocus")}.first
      focus_text = focus_header.next_element.text.strip
      (focus_text.present? and focus_text != "&nbsp") ? focus = focus_text : focus = nil

      history_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("HistoryInformation")}.first
      history_text = history_header.next_element.text.strip
      (history_text.present? and history_text != "&nbsp") ? history = history_text : history = nil

      #flag if no contact information, otherwise get it
      contact = {}
      contact_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("ContactInformation")}.first
      contact_paragraph = contact_header.next_element.text

      contact[:name] = contact_paragraph.scan(/Contact: (.*)/) if contact_paragraph.scan(/Contact: (.*)/).present?
      contact[:phone] = contact_paragraph.scan(/Phone: (.*)/) if contact_paragraph.scan(/Phone: (.*)/).present?
      contact[:fax] = contact_paragraph.scan(/Fax: (.*)/) if contact_paragraph.scan(/Fax: (.*)/).present?
      contact[:mobile] = contact_paragraph.scan(/Mobile: (.*)/) if contact_paragraph.scan(/Mobile: (.*)/).present?
      contact[:address] = contact_paragraph.scan(/Address: (.*)/) if contact_paragraph.scan(/Address: (.*)/).present?
      contact[:email] = contact_paragraph.scan(/E-mail: (.*)/) if contact_paragraph.scan(/E-mail: (.*)/).present?
      contact[:website] = contact_paragraph.scan(/Website: (.*)/) if contact_paragraph.scan(/Website: (.*)/).present?

      no_contact_info_flag = true
      contact.each do |key,value|
        if (value.empty? or !value[0][0].present?)
          contact[key] = nil
        else
          contact[key] = value[0][0].strip
          no_contact_info_flag = false
        end
      end
      warnings << "No contact information" if no_contact_info_flag

      #labels should become tags, warn if no labels
      label_links = page.css(".label-list > .label-container > .label")
      tags_from_labels = []
      label_links.each do |label_link|
        tags_from_labels << label_link.text.strip if label_link.text.present?
      end
      warnings << "No tags from labels" if tags_from_capabilities.empty? 

      carrier << {tags: tags_from_capabilities.concat(tags_from_labels), 
              warnings: warnings,
              contact: contact,
              url: url,
              update: update,
              longform: "Wiki history: #{history} Wiki focus: #{focus} Wiki synopsis: #{synopsis}"
            }
    end

    return carrier 

  end

end