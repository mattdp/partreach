class ReviewsController < ApplicationController

  def new
    @review = Review.new

    render layout: "old_layout"
  end

  def create

    params = clean_params

    @review = Review.new(review_params)
    @review.user_id = current_user.id

    respond_to do |format|
      if @review.save
        format.html { redirect_to orders_path, notice: 'Review was successfully submitted. Thanks!' }
        format.json { render json: orders_path }
      else
        format.html { render action: "new" }
        format.json { render json: @review.errors.full_messages, status: 400 }
      end
    end
  end

  private

    def review_params
      params.permit(:company, :process, :part_type, :would_recommend, :quality, \
                    :adaptability, :delivery, :did_well, :did_badly
                    )
    end

end