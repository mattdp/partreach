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
  def self.upload_wiki_page
    

  end

end