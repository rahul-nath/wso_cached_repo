class Bulletins::LostFoundsController < BulletinsController

  def index
    @bulletins = LostFound.paginate(page: params[:page])

    respond_to do |format|
      format.json { render json: LostFound.all }
      format.html { render template: 'bulletins/shared/index' }
    end
  end

  # GET /lost_founds/new
  # GET /lost_founds/new.json
  def new
    @bulletin = @current_user.lost_founds.build
    super
  end

  # POST /lost_founds
  # POST /lost_founds.json
  def create
    @bulletin = current_user.lost_founds.build(bulletin_params)
    super
  end

  private

  def set_page_class
    @page_class = LostFound
  end

  # Note that this is also used in BulletinsController
  def bulletin_params
    params.require(:lost_found).permit(:title,
                                       :body)
  end
  
end
