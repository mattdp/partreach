require 'spec_helper'

describe TagRelationship do

  let(:tagA) { FactoryGirl.create :tag }
  let(:tagB) { FactoryGirl.create :tag }
  let(:tagX) { FactoryGirl.create :tag }
  let(:tagY) { FactoryGirl.create :tag }
  let(:tagZ) { FactoryGirl.create :tag }

  it "allows a tag to be related to another tag" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: "r1")
    tagA.related_tags.should == [tagX]
  end

  it "allows a tag to be related to multiple other tags" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: "r1")
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagY, relationship: "r1")
    tagA.related_tags.should =~ [tagX, tagY]
  end

  it "allows a tag to be related to multiple other tags with a specified relationships" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: "r1")
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagY, relationship: "r2")
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagZ, relationship: "r1")
    tagA.related_tags.where("relationship='r1'").should =~ [tagX, tagZ]
  end

  it "allows a tag to identify another tag related to it" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: "r1")
    tagX.source_tags.should == [tagA]
  end

  it "allows a tag to identify other tags related to it with a specified relationship" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: "r1")
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagY, relationship: "r2")
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagZ, relationship: "r1")
    tagB.tag_relationships << TagRelationship.new(source_tag:tagB, related_tag:tagX, relationship: "r1")
    tagX.source_tags.where("relationship='r1'").should =~ [tagA, tagB]
  end
end
