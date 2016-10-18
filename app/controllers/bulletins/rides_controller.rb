class Bulletins::RidesController < BulletinsController

  def index
    @bulletins = Ride.alive.paginate(page: params[:page])

    respond_to do |format|
      format.json { render json: Ride.all }
      format.html { render template: 'bulletins/shared/index' }
    end
  end

  def new
    @bulletin = current_user.rides.build
    super
  end

  def create
    @bulletin = current_user.rides.build(bulletin_params)
    super
  end

  private

  def set_page_class
    @page_class = Ride
  end
  
  def bulletin_params
    params.require(:ride).permit(:body,
                                 :source, 
                                 :destination,
                                 :start_date,
                                 :offer)
  end

end
