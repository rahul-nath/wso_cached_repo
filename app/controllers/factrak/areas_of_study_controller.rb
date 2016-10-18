class Factrak::AreasOfStudyController < FactrakController

  def show
    @area_of_study = AreaOfStudy.find_by(id: params[:id])
    redirect_to request.referer || "/factrak" and return if @area_of_study.nil?
    @professors = @area_of_study.department.professors

    respond_to do |format|
      format.html
      format.json { render json: @area_of_study }
    end
  end
end
