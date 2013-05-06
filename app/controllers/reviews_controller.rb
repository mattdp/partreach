class ReviewsController < ApplicationController
	before_filter :signed_in_user

	def new
		@review = Review.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review }
    end
	end

	def create

		@review = Review.create(
			company: params[:company],
			process: params[:process],
			part_type: params[:part_type],
			would_recommend: params[:would_recommend],
			quality: params[:quality],
			adaptability: params[:adaptability],
			delivery: params[:delivery],
			did_well: params[:did_well],
			did_badly: params[:did_badly],
			user_id: current_user.id
			)

		respond_to do |format|
			if @review
				format.html { redirect_to orders_path, notice: 'Review was successfully submitted. Thanks!' }
				format.json { render json: orders_path }
			else
				format.html { render action: "new" }
				format.json { render json: @review.errors.full_messages, status: 400 }
			end
		end
	end

end