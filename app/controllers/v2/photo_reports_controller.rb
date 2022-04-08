class V2::PhotoReportsController < UserController
  attr_reader :current_user
  before_action :snake_case_params

  has_scope :unreviewed, type: :boolean
  has_scope :unreviewed_by_me, type: :boolean do |controller, scope|
    scope.unreviewed_by(controller.current_user.id)
  end

  def index
    @photo_reports = policy_scope(PhotoReport).order("photo_reports.id DESC").includes(:daily_report, :patient, :organization).has_daily_report
    @photo_reports = apply_scopes(@photo_reports)

    if (params.has_key?(:patient_id))
      authorize Patient.find(params[:patient_id]), :show?, policy_class: PatientPolicy
      @photo_reports = @photo_reports.where(user_id: params[:patient_id])
    end

    if (params["include_skipped"] == "false")
      @photo_reports = @photo_reports.where("photo_url is not null")
    end

    if (params.has_key?(:offset))
      @photo_reports = @photo_reports.offset(params[:offset])
    end

    first_report_ids = PhotoReport.has_daily_report.all.group(:user_id).minimum(:id).values

    render(json: @photo_reports.limit(10), current_user: @current_user, first_report_ids: first_report_ids, status: :ok)
  end

  def show
    @photo_report = PhotoReport.find(params[:id])
    authorize @photo_report
    render(json: @photo_report, status: :ok)
  end

  def create
    daily_report = DailyReport.create_if_not_exists(@current_user.id, params["date"])
    daily_report.update!(photo_report: @current_user.photo_reports.create!(photo_report_params))
    render(json: daily_report, status: :created)
  end

  def update
    @photo_report = PhotoReport.find(params[:id])
    authorize @photo_report
    @photo_report.update!(update_params)
    send_redo_notification_if_needed
    render(json: @photo_report, status: :ok)
  end

  private

  def send_redo_notification_if_needed
    if (params[:redo_flag])
      @photo_report.send_redo_notification
    end
  end

  def update_params
    params.permit(:approved, :redo_flag, :redo_reason).merge(approval_timestamp: Time.current, practitioner_id: @current_user.id)
  end

  def photo_report_params
    #Modify to allow for no photo submission if opt out options are given
    if (params[:photo_was_skipped] == true)
      params.require([:date, :why_photo_was_skipped])
    else
      params.require([:date, :photo_url])
    end

    params.permit(:date, :back_submission, :photo_url, :captured_at, :why_photo_was_skipped, :photo_was_skipped, :redo_for_report_id)
  end
end
