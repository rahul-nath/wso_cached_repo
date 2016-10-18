class Dormtrak::DormtrakReviewsController < ApplicationController

  before_action :ensure_authorization, only: [:show]
  before_action :ensure_authorization_for_index, only: :index
  before_action :ensure_student
  before_action :ensure_dorm, only: [:new, :create]
  before_action :ensure_new_review, only: [:new, :create]
  before_action :ensure_ownership, only: [:edit, :update, :destroy]

  layout 'dormtrak'

  def index
    @reviews = DormtrakReview.all
    @reviews = @reviews.take(params[:limit].to_i) if params[:limit]
    respond_to do |format|
      format.json { render json: @reviews }
    end
  end

  def show
    @review = DormtrakReview.find_by(id: params[:id])
    respond_to do |format|
      format.json { render json: @review }
    end
  end

  def new
    @dorm = current_user.dorm
    @review = @dorm.dormtrak_reviews.build
  end

  def create
    # what if reviewing not their current one?
    @room = current_user.dorm_room
    @dorm = @room.dorm

    # Associate the review with the room
    @review = @dorm.dormtrak_reviews.build(review_params)
    @review.dorm_room = @room
    @review.user = current_user

    if @review.save
      flash[:success] = "Successfully saved review."
      redirect_to [:dormtrak, @dorm]
    else
      flash.now[:notice] = "Could not save review."
      render 'new'
    end
  end

  def edit
  end

  def update
    @review.comment = params[:dormtrak_review][:comment]
    @review.noise   = params[:dormtrak_review][:noise]

    if @review.save
      flash[:success] = "Comment updated."
      redirect_to '/dormtrak'
    else
      render 'edit'
    end
  end

  def destroy
    @review.destroy
    flash[:notice] = "Review deleted."
    redirect_to '/dormtrak'
  end
  
  protected

  def ensure_dorm
    unless current_user.dorm
      flash[:notice] = "You don't seem to have a dorm. If you actually do, contact us"
      redirect_to '/dormtrak'
    end
  end

  def ensure_new_review
    if current_user.has_reviewed_room?
      flash[:notice] = "You've already reviewed your room."
      redirect_to '/dormtrak'
    end    
  end

  def ensure_ownership
    @review = DormtrakReview.find(params[:id])
    unless current_user.can_edit_review(@review)
      flash[:notice] = "You do not have permission to do that."
      redirect_to '/dormtrak'
    end
  end

  private

  def review_params
    params.require(:dormtrak_review).permit(:user_id,
                                            :dorm_id,
                                            :room_id,
                                            :comment,
                                            :lived_here,
                                            :closet,
                                            :flooring,
                                            :common_room_access,
                                            :common_room_desc,
                                            :thermostat_access,
                                            :thermostat_desc,
                                            :outlets_desc,
                                            :key_or_card,
                                            :noise,
                                            :bed_adjustable,
                                            :anonymous,
                                            :capacity,
                                            :faces,
                                            :private_bathroom,
                                            :bathroom_desc,
                                            :picture,
                                            :comfort,
                                            :loudness,
                                            :convenience,
                                            :wifi, 
                                            :location,
                                            :satisfaction)
  end

end
