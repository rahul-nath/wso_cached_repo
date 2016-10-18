class Factrak::CoursesController < FactrakController
  
  def show
    @course = Course.find_by(id: params[:id])
    redirect_to request.referer || "/factrak" and return if @course.nil?
    @comments = @course.surveys.commented
    if params[:prof]
      @comments = @comments.select { |c| c.professor_id.to_s == params[:prof].to_s }
    end
    respond_to do |format|
      format.json { render json: @course.to_json(include: [:department]) }
      format.html
    end

  end
end
