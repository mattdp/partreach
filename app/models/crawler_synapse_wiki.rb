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

    example_urls = ["https://s3.amazonaws.com/temp_for_uploading/1.html",
      "https://s3.amazonaws.com/temp_for_uploading/2.html",
      "https://s3.amazonaws.com/temp_for_uploading/3.html",
      "https://s3.amazonaws.com/temp_for_uploading/4.html"]

    urls = [example_urls[0]] #so everything else works once we have the real ones

    urls.each do |url|
      page = Nokogiri::HTML(open(url))
      div_wiki_content = page.css('#content > div.wiki-content')
      div_wiki_content_headers = div_wiki_content.css("h2")
      warnings = []

      #DONE bullet points under capabilities, to make into tags
      tags_from_capabilities = [] 
      capability_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("Capabilities")}.first
      capability_list = capability_header.next_element
      capability_list.css("li").each do |li|
        tags_from_capabilities << li.text.strip if li.text.present?
      end
      warnings >> "No tags from capabilties" if tags_from_capabilities.empty? 
      
      #flag if noncompete content 
      div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("DoNotCompeteWith")}.first
      #need to check for content and flag it, after question
        
      #flag if no contact information, otherwise get it
      
      #DONE labels should become tags
      label_links = page.css(".label-list > .label-container > .label")
      tags_from_labels = []
      label_links.each do |label_link|
        tags_from_labels << label_link.text.strip if label_link.text.present?
      end
      warnings >> "No tags from labels" if tags_from_capabilities.empty? 

      return tags_from_capabilities.concat(tags_from_labels), warnings
    end 

  end

end