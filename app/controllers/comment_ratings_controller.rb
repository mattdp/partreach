class CommentRatingsController < ApplicationController
  before_filter :hax_access_only

  def create
    provider = Provider.find(params[:provider_id])
    helpful = ( params[:commit] == 'Yes' )
    unless CommentRating.add_rating(params[:comment_id], current_user, helpful)
      note = "Sorry, unable to save your comment rating"
    end

    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

end