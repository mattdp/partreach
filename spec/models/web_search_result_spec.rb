require 'spec_helper'

describe WebSearchResult do

  before :each do
    @wsr1 = FactoryGirl.create(:web_search_result, domain: "aaa.com")
    @wsr2 = FactoryGirl.create(:web_search_result, domain: "bbb.com")
    @wsr3 = FactoryGirl.create(:web_search_result, domain: "ccc.com")
    @wsr4 = FactoryGirl.create(:web_search_result, domain: "bbb.com")
  end

  let (:examiner) {FactoryGirl.create :examiner_user}
  let (:supplier) {FactoryGirl.create :supplier}

  describe "scope :matches_exclusions" do
    it "selects all items with domains in the exlusions list" do
      @e1 = FactoryGirl.create(:search_exclusion, domain: "bbb.com")
      @e2 = FactoryGirl.create(:search_exclusion, domain: "xyz.com")
      @e3 = FactoryGirl.create(:search_exclusion, domain: "aaa.com")
      expect(WebSearchResult.matches_exclusions).to match_array([@wsr1, @wsr2, @wsr4])
    end
  end

  describe "scope :matches_suppliers" do
    it "selects all items with root domains of existing suppliers" do
      @s1 = FactoryGirl.create(:supplier, url_main: "http://www.ccc.com/index.asp")
      @s2 = FactoryGirl.create(:supplier, url_main: "http://www.xyz.com")
      @s3 = FactoryGirl.create(:supplier, url_main: "https://www.bbb.com/3d_printing")
      expect(WebSearchResult.matches_suppliers).to match_array([@wsr2, @wsr3, @wsr4])
    end
  end

  describe "#record_action" do
    it "keeps track of which user took an action, and what choice they made" do
      @wsr1.record_action("not_supplier", examiner)

      wsr = WebSearchResult.find(@wsr1.id)
      expect(wsr.action).to eq "not_supplier"
      expect(wsr.action_taken_by).to eq examiner
    end

    it "keeps track of associated supplier, when given" do
      @wsr3.record_action("add_supplier", examiner, supplier)

      wsr = WebSearchResult.find(@wsr3.id)
      expect(wsr.supplier).to eq supplier
    end

    it "marks other search results with same domain as duplicate" do
      @wsr2.record_action("not_supplier", examiner, supplier)

      wsr = WebSearchResult.find(@wsr4.id)
      expect(wsr.action).to eq "duplicate_domain"
    end
  end

end
