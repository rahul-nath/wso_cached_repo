class BulletinsController < ApplicationController
  before_action :ensure_user, except: [:index, :show]

  before_action :ensure_valid_id, only: [:edit, :update, :destroy]
  before_action :ensure_ownership, only: [:edit, :update, :destroy]

  before_action :set_page_class # defined in subclass

  # A bulletin subclass can override this if wants to
  # display in a special way
  def show
    @bulletin = Bulletin.find(params[:id])

    respond_to do |format|
      format.html { render "bulletins/shared/show" }
      format.json { render json: @bulletin }
    end
  end

  def new
    # @bulletin must be set in subclass before calling this
    respond_to do |format|
      format.html { render "bulletins/shared/_form" }
      format.json { render json: @bulletin }
    end
  end

  def create
    # @bulletin must be set in subclass before calling this    
    if @bulletin.save
      respond_to do |format|
        format.html { redirect_to @bulletin }
        format.json { render json: @bulletin, status: :created }
      end
    else
      respond_to do|format|
        format.html { render "bulletins/shared/_form" }
        format.json { render json: @bulletin.errors, status: :unprocessable_entity }
      end
    end    
  end

  def edit
    render "bulletins/shared/_form"
  end

  def update
    respond_to do |format|
      if @bulletin.update_attributes(bulletin_params)
        format.html { redirect_to @bulletin, notice: 'Successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bulletin.errors, status: :unprocessable_entity }
      end
    end    
  end

  def destroy
    @bulletin.destroy
    redirect_to @bulletin.class
  end

  protected

  def ensure_valid_id
    @bulletin = Bulletin.find_by(id: params[:id])
    forbidden "Record does not exist" if @bulletin.nil?
  end

  def ensure_ownership
    forbidden "Permission denied" unless current_user.owns?(@bulletin)
  end

  def set_page_class
  end
end
