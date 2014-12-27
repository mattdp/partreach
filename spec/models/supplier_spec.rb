require 'spec_helper'

describe "Supplier" do

  before :each do
    tag_group_1 = FactoryGirl.create(:tag_group, exclusive: true)
    @tag1a = FactoryGirl.create(:tag, tag_group: tag_group_1)
    @tag1b = FactoryGirl.create(:tag, tag_group: tag_group_1)
    @tag2 = FactoryGirl.create(:tag)
    @supplier = FactoryGirl.create(:supplier)
    @supplier.add_tag(@tag1a.id)
    @supplier.add_tag(@tag2.id)
  end

  it "can remove a tag" do
    @supplier.remove_tags(@tag2.id)
    @supplier.has_tag?(@tag2.id).should be_false
  end

  it "can have tags added from different tag groups" do
    @supplier.has_tag?(@tag1a.id).should be_true
    @supplier.has_tag?(@tag2.id).should be_true
  end

  describe "exclusive tags" do
    before { @supplier.add_tag(@tag1b.id) }
    it "should delete other tags in its tag_group when added" do
      @supplier.has_tag?(@tag1a.id).should be_false
    end
    it "should retain other tags not in its tag_group when added" do
      @supplier.has_tag?(@tag2.id).should be_true
    end
  end

  describe "double tags" do
    before { @supplier.add_tag(@tag1b.id) }
    it "should return false when attempting to re-add a tag" do
      @supplier.add_tag(@tag1b.id).should be_false
    end
  end

  describe "pending_examination" do
    it "returns the count of suppliers tagged 'datadump'" do
      @supplier.add_tag(Tag.find_by_name 'datadump')
      Supplier.pending_examination.should == 1
    end
  end

  describe "quantity_by_tag_id" do
    it "returns an array of suppliers with the specified tag, country and state" do
      t1 = FactoryGirl.create(:tag, tag_group: FactoryGirl.create(:tag_group))
      s1 = FactoryGirl.create(:supplier)
      s2 = FactoryGirl.create(:supplier)
      s1.add_tag(t1)
      country = s1.address.country.short_name
      state = s1.address.state.short_name
      Supplier.quantity_by_tag_id("all", t1.id, country, state).should == [s1]
    end
  end

end
