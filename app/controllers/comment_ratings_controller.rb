class CommentRatingsController < ApplicationController
  before_filter :hax_access_only

  def create
    provider = Provider.find(params[:provider_id])
    comment_id = params[:comment_id]
    helpful = ( params[:commit] == 'Yes' )

    comment_rating_id = CommentRating.add_rating(comment_id, current_user, helpful)
    if comment_rating_id
      Event.add_event("User", current_user.id, "added rating on comment", "Comment", comment_id)
    else
      note = "Sorry, unable to save your comment rating"
    end

    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

end