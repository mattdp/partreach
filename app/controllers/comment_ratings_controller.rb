class CommentRatingsController < ApplicationController
  before_filter :hax_access_only

  def create
    provider = Provider.find(params[:provider_id])
    helpful = ( params[:commit] == 'Yes' )
    comment_rating = CommentRating.new(comment_id: params[:comment_id], user: current_user, helpful: helpful)
    saved_ok = comment_rating.save

    if !saved_ok
      note = "Sorry, unable to save your comment rating"
    end

    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

end