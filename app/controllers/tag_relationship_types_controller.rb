class TagRelationshipTypesController < ApplicationController
  def index
    @relationship_types = TagRelationshipType.all

    respond_to do |format|
      format.json {render 'index'}
    end
  end
end