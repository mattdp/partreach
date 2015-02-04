# == Schema Information
#
# Table name: tag_relationships
#
#  id                       :integer          not null, primary key
#  source_tag_id            :integer          not null
#  related_tag_id           :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#  tag_relationship_type_id :integer          not null
#

require 'spec_helper'

describe TagRelationship do

  let(:group1) { FactoryGirl.create :tag_group }
  let(:group2) { FactoryGirl.create :tag_group }
  let(:group3) { FactoryGirl.create :tag_group }
  let(:tagA) { FactoryGirl.create :tag, tag_group: group1}
  let(:tagB) { FactoryGirl.create :tag, tag_group: group1}
  let(:group2) { FactoryGirl.create :tag_group }
  let(:tagX) { FactoryGirl.create :tag, tag_group: group2}
  let(:tagY) { FactoryGirl.create :tag, tag_group: group3}
  let(:tagZ) { FactoryGirl.create :tag, tag_group: group2}
  let(:r1) { FactoryGirl.create :tag_relationship_type, name: 'r1', source_group: group1, related_group: group2 }
  let(:r2) { FactoryGirl.create :tag_relationship_type, name: 'r2', source_group: group1, related_group: group2 }

  it "allows a tag to be related to another tag" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: r1)
    tagA.related_tags.should == [tagX]
  end

  it "allows a tag to be related to multiple other tags" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: r1)
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagY, relationship: r2)
    tagA.related_tags.should =~ [tagX, tagY]
  end

  it "allows a tag to be related to multiple other tags with a specified relationships" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: r1)
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagY, relationship: r2)
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagZ, relationship: r1)
    tagA_related_tags_via_r1 =
      Tag.joins(reverse_tag_relationships: :relationship).
      where("tag_relationships.source_tag_id=#{tagA.id}").
      where("tag_relationship_types.name='r1'")
    tagA_related_tags_via_r1.should =~ [tagX, tagZ]
  end

  it "allows a tag to identify another tag related to it" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: r1)
    tagX.source_tags.should == [tagA]
  end

  it "allows a tag to identify other tags related to it with a specified relationship" do
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagX, relationship: r1)
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagY, relationship: r2)
    tagA.tag_relationships << TagRelationship.new(source_tag:tagA, related_tag:tagZ, relationship: r1)
    tagB.tag_relationships << TagRelationship.new(source_tag:tagB, related_tag:tagX, relationship: r1)
    # r1_source_tags = Tag.joins(tag_relationships: :relationship).where("tag_relationship_types.name='r1'")
    tagX_source_tags_via_r1 =
      Tag.joins(tag_relationships: :relationship).
      where("tag_relationships.related_tag_id=#{tagX.id}").
      where("tag_relationship_types.name='r1'")
    tagX_source_tags_via_r1.should =~ [tagA, tagB]
  end
end
