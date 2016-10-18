class Bulletins::JobsController < BulletinsController

  def index
    @bulletins = Job.paginate(page: params[:page])

    respond_to do |format|
      format.json { render json: Job.all }
      format.html { render template: 'bulletins/shared/index' }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @bulletin = @current_user.jobs.build
    super
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @bulletin = current_user.jobs.build(bulletin_params)
    super
  end

  private

  def set_page_class
    @page_class = Job
  end

  # Note that this is also used in BulletinsController
  def bulletin_params
    params.require(:job).permit(:title,
                                :body)
  end

end
