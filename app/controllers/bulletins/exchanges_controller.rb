class Bulletins::ExchangesController < BulletinsController

  before_action :ensure_user, :only => [:new, :create, :edit]

  def index
    @bulletins = Exchange.paginate(page: params[:page])

    respond_to do |format|
      format.json { render json: Exchange.all }
      format.html { render template: 'bulletins/shared/index' }
    end
  end

  # GET /exchanges/new
  # GET /exchanges/new.json
  def new
    @bulletin = @current_user.exchanges.build
    super
  end

  # POST /exchanges
  # POST /exchanges.json
  def create
    @bulletin = current_user.exchanges.build(bulletin_params)
    super
  end

  private

  def set_page_class
    @page_class = Exchange
  end

  # Note that this is also used in BulletinsController
  def bulletin_params
    params.require(:exchange).permit(:title,
                                     :body)
  end
  
end
