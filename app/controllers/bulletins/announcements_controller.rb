class Bulletins::AnnouncementsController < BulletinsController

  before_action :ensure_user, :only => [:new, :create, :edit]

  # GET /announcements
  # GET /announcements.json
  def index
    @bulletins = Announcement.alive.paginate(page: params[:page])

    respond_to do |format|
      format.html { render template: 'bulletins/shared/index' }
      format.json { render json: Announcement.all }
    end
  end

  # GET /announcements/new
  # GET /announcements/new.json
  def new
    @bulletin = @current_user.announcements.build
    super
  end

  # POST /announcements
  # POST /announcements.json
  def create
    @bulletin = current_user.announcements.build(bulletin_params)
    super
  end

  private

  def set_page_class
    @page_class = Announcement
  end

  # Note that this is also used in BulletinsController
  def bulletin_params
    params.require(:announcement).permit(:title,
                                         :body,
                                         :start_date)
  end

end
