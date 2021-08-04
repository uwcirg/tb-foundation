class V2::ContactTracingSurveysController < PatientDataController
  #before_action :set_contact_tracing_survey, only: [:show, :update, :destroy]

  # GET /contact_tracing_surveys
  def index
    @contact_tracing_surveys = ContactTracingSurvey.all
    render json: @contact_tracing_surveys
  end

  # POST /contact_tracing_surveys
  def create

    @contact_tracing_survey = @current_user.contact_tracing_surveys.new(contact_tracing_survey_params)

    authorize @contact_tracing_survey

    if @contact_tracing_survey.save
      render json: @contact_tracing_survey, status: :created
    else
      render json: @contact_tracing_survey.errors, status: :unprocessable_entity
    end

  end

  private

    # def set_patient
    #   @relevant_patient = Patient.find(params[:patient_id])
    # end

    # Use callbacks to share common setup or constraints between actions.
    def set_contact_tracing_survey
      @contact_tracing_survey = ContactTracingSurvey.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def contact_tracing_survey_params
      params.require(:contact_tracing_survey).permit(:number_of_contacts, :number_of_contacts_tested, :patient_id)
    end
end
