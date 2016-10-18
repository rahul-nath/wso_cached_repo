class Factrak::ProfessorsController < FactrakController

  def show
    @prof = Professor.find_by(id: params[:id])
    @survey = FactrakSurvey.new
    @comments = @prof.surveys.commented

    respond_to do |format|
      format.json { render json: @prof.to_json(include: [ {:room => {include: :building}}, :department]) }
      format.html
    end
  end

end
