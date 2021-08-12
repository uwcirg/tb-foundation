class V2::ActivationController < UserController
  before_action :snake_case_params

  def create
    set_patient
    authorize @patient, :activate?
    initalize_notification_preference
    create_contact_tracing_survey
    update_patient_attributes
    render(json: @patient, status: 200)
  end

  private

  #Maybe we should move this to another controller for use across various controllser in a DRY way
  def set_patient
    @patient = Patient.find(params[:patient_id] == "self" ? @current_user.id : params[:patient_id])
  end

  def update_patient_attributes
    @patient.add_photo_day(params[:date] || @patient.localized_date)
    @patient.update(update_patient_params.merge(:app_start => DateTime.current, :status => "Active"))
    @patient.activate
    @patient.save!
  end

  def initalize_notification_preference
    if (params[:enable_notifications] == true)
      @patient.update_daily_notification(params[:notification_time])
    end
  end

  def create_contact_tracing_survey
    @patient.contact_tracing_surveys.create!(contact_tracing_params)
  end

  def contact_tracing_params
    params.require(:contact_tracing_survey).permit(:number_of_contacts, :number_of_contacts_tested)
  end

  def update_patient_params
    params.require(:patient).permit(:gender, :gender_other, :age)
  end
end
