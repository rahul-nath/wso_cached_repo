class Factrak::FactrakAgreementsController < FactrakController

  def create
    @survey = FactrakSurvey.find(params[:factrak_survey_id])
    FactrakAgreement.where(user: current_user, survey: @survey).destroy_all
    @agreement = FactrakAgreement.create(agreement_params.merge(user: current_user))
    respond_to do |format|
      format.js
    end
  end

  private

  def agreement_params
    params.permit(:agrees, :factrak_survey_id)
  end

end
