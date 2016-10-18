class Dormtrak::NeighborhoodsController < ApplicationController

  before_action :ensure_authorization, only: [:show]
  before_action :ensure_authorization_for_index, only: :index

  layout 'dormtrak'
  
  def index
    @neighborhoods = Neighborhood.all
    respond_to do |format|
      format.json { render json: @neighborhoods }
    end
  end

  def show    
    respond_to do |format|
      format.json do 
        @neighborhood = Neighborhood.where(id: params[:id]).first
        render json: @neighborhood
      end
      format.html do
        @neighborhood = Neighborhood.where("lower(name) = ?", params[:id].downcase).first
        redirect_to '/dormtrak' unless @neighborhood
      end
    end
  end

  def update
  end

end
