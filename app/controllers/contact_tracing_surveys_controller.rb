class ContactTracingSurveysController < ApplicationController
  before_action :set_contact_tracing_survey, only: [:show, :update, :destroy]

  # GET /contact_tracing_surveys
  def index
    @contact_tracing_surveys = ContactTracingSurvey.all

    render json: @contact_tracing_surveys
  end

  # POST /contact_tracing_surveys
  def create
    @contact_tracing_survey = ContactTracingSurvey.new(contact_tracing_survey_params)

    if @contact_tracing_survey.save
      render json: @contact_tracing_survey, status: :created, location: @contact_tracing_survey
    else
      render json: @contact_tracing_survey.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_tracing_survey
      @contact_tracing_survey = ContactTracingSurvey.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def contact_tracing_survey_params
      params.require(:contact_tracing_survey).permit(:number_of_contacts, :number_of_contacts_tested, :patient_id)
    end
end
