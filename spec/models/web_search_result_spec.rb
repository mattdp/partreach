require 'spec_helper'

describe WebSearchResult do

  before :each do
    @a = FactoryGirl.create(:web_search_result, domain: "aaa.com")
    @b1 = FactoryGirl.create(:web_search_result, domain: "bbb.com")
    @c = FactoryGirl.create(:web_search_result, domain: "ccc.com")
    @b2 = FactoryGirl.create(:web_search_result, domain: "bbb.com")
  end

  describe "scope :matches_exclusions" do
    it "selects all items with domains in the exlusions list" do
      FactoryGirl.create(:search_exclusion, domain: "ccc.com")
      FactoryGirl.create(:search_exclusion, domain: "xyz.com")
      FactoryGirl.create(:search_exclusion, domain: "bbb.com")

      expect(WebSearchResult.matches_exclusions.size).to eq 3
    end
  end

  describe "scope :matches_suppliers" do
    it "selects all items with root domains of existing suppliers" do
      FactoryGirl.create(:supplier, url_main: "http://www.ccc.com/index.asp")
      FactoryGirl.create(:supplier, url_main: "http://www.xyz.com")
      FactoryGirl.create(:supplier, url_main: "https://www.bbb.com/3d_printing")

      expect(WebSearchResult.matches_suppliers.size).to eq 3
    end
  end

  describe "#self.delete_all_with_matching_domain" do
    context "when selected item has unique domain" do
      it "deletes that item only" do
        WebSearchResult.delete_all_with_matching_domain(@a.id)

        expect(WebSearchResult.all.size).to eq 3
        expect(WebSearchResult.where("domain = 'aaa.com'").size).to eq 0
      end
    end

    context "when other items have same domain as selected item" do
      it "deletes selected item and all other items with matching domain" do
        WebSearchResult.delete_all_with_matching_domain(@b1.id)

        expect(WebSearchResult.all.size).to eq 2
        expect(WebSearchResult.where("domain = 'bbb.com'").size).to eq 0
      end
    end

    context "when selected item has already been deleted" do
      it "does not delete any items" do
        id = @b1.id
        @b1.destroy!
        WebSearchResult.delete_all_with_matching_domain(id)

        expect(WebSearchResult.all.size).to eq 3
      end
    end
  end

end
