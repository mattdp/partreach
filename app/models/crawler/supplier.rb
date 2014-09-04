class Crawler::Supplier < CrawlerRefactor
  def initialize(supplier, args)
    return false if supplier.url_main.blank?
    super(args)
    @supplier = supplier
    args[:url] = @supplier.url_main
    @site_info = {
      phone: [],
      email: [],
      zip: [],
      state: []
    }
    @data = {}
  end

  def run
    @html_documents = super
    parse_data
    determine_frequency
    save_data
  end

  private
    def parse_data
      @html_documents.each do |page|
        text = page.text
        #states generally live near zip codes
        site_info[:zip] << text.scan(/[A-Z]{2}[\s,]+(\d{5})/)
        site_info[:state] << text.scan(/([A-Z]{2})[\s,]+\d{5}/)
        #phone-groups of 3 3 4 separated by at most 2 of any char, without numbers on either end
        site_info[:phone] << text.scan(/(\d{3,4}).{,2}(\d{3}).{,2}(\d{4})/)
        site_info[:email] << text.scan(/([\w+\-.]+@[a-z\d\-.]+\.[a-z]{1,5})\s/i)
      end
    end

    def determine_frequency
      @site_info.each do |attribute,values| #ie {phone: [[["230","424","9334"],["432","545","2341"]]]}
        if values.flatten.any?
          #get a workable list from the convoluted .scan structure
          values = attribute != :phone ? values.flatten : values.flatten.map{|a,b,c| "#{a}#{b}#{c}"}
          #get a frequency distribution
          #http://stackoverflow.com/questions/9480852/array-to-hash-words-count
          frequency = Hash.new(0)
          values.map{ |value| frequency[value] += 1 }
          #take the top ones
          @data[attribute] = frequency.max_by{|k,v| v}[0]
        else
          @data[attribute] = nil
        end
      end
    end

    def save_data
      logger.info "---CRAWLER RAW OUTPUT---"
      logger.info @data
      logger.info "---END CRAWLER RAW OUTPUT---"

      contact = @supplier.rfq_contact
      address = @supplier.address

      contact.email = @data[:email] if @data[:email].present? && contact.email.blank?
      contact.phone = @data[:phone] if @data[:phone].present? && contact.phone.blank?
      address.zip = @data[:zip] if @data[:zip].present? && address.zip.blank?
      address.state_id = Geography.locate(@data[:state],:short_name,"state").id if @data[:state].present? && address.state_id.blank? 

      if (save_s = supplier.save and save_a = address.save and save_c = contact.save) 
        $stdout.print "All saves OK: "
      else
        {save_s => "Supplier",save_a => "Address",save_c => "Contact"}.each do |value,model|
          $stdout.print "Error saving #{model}" unless value
        end
      end
      logger.info "#{@supplier.name} processed."
    end
end