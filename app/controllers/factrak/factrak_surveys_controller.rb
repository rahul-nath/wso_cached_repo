class Factrak::FactrakSurveysController < FactrakController
  before_action :ensure_ownership, only: [:edit, :update, :destroy]

  def index
    @surveys = current_user.factrak_surveys
  end

  def new
    @survey = current_user.factrak_surveys.build
    @prof = Professor.find(params[:professor_id])
  end

  def create
    @survey = current_user.factrak_surveys.build(survey_params)

    if @survey.save
      redirect_to [:factrak, @survey.professor]
    else
      @prof = @survey.professor
      render "new"
    end
  end

  def edit
    @prof = @survey.professor
    if @survey.course
      @survey.aos_abbrev = @survey.course.area_of_study.abbrev
      @survey.course_num = @survey.course.number
    end
  end

  def update
    if @survey.update(survey_params)
      redirect_to [:factrak, @survey.professor]
    else
      render "edit"
    end
  end

  def destroy
    @survey.destroy
    flash[:notice] = "Review destroyed successfully"
    redirect_to request.referer || factrak_path
  end

  def show
    @survey = FactrakSurvey.find_by(id: params[:id])
    respond_to do |format|
      format.json { render json: @survey.to_json(include: [:user, :professor, {:course => {:include => :department}}]) }
    end
  end

  private

  def ensure_ownership
    @survey = FactrakSurvey.find(params[:id])
    unless current_user.can_edit_review(@survey)
      flash[:notice] = "You do not have permission to do that."
      redirect_to factrak_path
    end
  end

  def survey_params
    params.require(:factrak_survey).permit(:professor_id,
                                           :user_id,
                                           :course_id,
                                           :would_recommend_course,
                                           :course_workload,
                                           :would_take_another,
                                           :approachability,
                                           :course_stimulating,
                                           :lead_lecture,
                                           :promote_discussion,
                                           :outside_helpfulness,
                                           :comment,
                                           :aos_abbrev,
                                           :course_num)
  end
end
