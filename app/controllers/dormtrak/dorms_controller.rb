class Dormtrak::DormsController < ApplicationController
  include DormtrakHelper
  # Currently set to only allow people who've logged in
  before_action :ensure_authorization, only: [:show]
  before_action :ensure_authorization_for_index, only: :index
  before_action :ensure_student, only: [:new, :create]
  before_action :ensure_dormtrak_policy_acceptance, except: [:accept_policy, :policy]

  layout 'dormtrak'

  def index
    @dorms = Dorm.all
    @dorms = @dorms.take(params[:limit].to_i) if params[:limit]
    respond_to do |format|
      format.json { render json: @dorms }
    end
  end

  def show
    @dorm = Dorm.trakked.where("lower(name) = ?", params[:id].downcase).first

    respond_to do |format|
      format.html do
        if @dorm.nil?
          redirect_to '/dormtrak' and return
        end
        @reviews = @dorm.recent_reviews
      end
      
      format.json { render json: @dorm }
    end
  end

  def update
  end

  private

  def dorm_params
    params.require(:dorm).permit(:neighborhood_id,
                                 :number_reviews,
                                 :name,
                                 :key_or_card,
                                 :description,
                                 :built,
                                 :capacity,
                                 :number_bathrooms,
                                 :number_singles,
                                 :number_doubles,
                                 :number_washers,
                                 :seniors,
                                 :juniors,
                                 :sophomores,
                                 :freshmen,
                                 :bathroom_ratio,
                                 :comfort,
                                 :loudness,
                                 :convenience,
                                 :wifi,
                                 :location, 
                                 :satisfaction)
  end

end
