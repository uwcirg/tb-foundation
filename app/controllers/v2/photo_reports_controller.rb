class V2::PhotoReportsController < UserController
  before_action :snake_case_params

  def index

    @photo_reports = policy_scope(PhotoReport).order("photo_reports.id DESC").includes(:daily_report, :patient, :organization).has_daily_report

    if (params["include_reviewed"] == "false")
      sanitized_join = ActiveRecord::Base.sanitize_sql_array(["LEFT JOIN photo_reviews on photo_reviews.photo_report_id = photo_reports.id AND photo_reviews.bio_engineer_id = ?", @current_user.id])
      @photo_reports = @photo_reports.joins(sanitized_join).where("photo_reviews.id IS NULL")
    end

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
    @photo_report.update(update_params)
    @photo_report.update(approval_timestamp: Time.current, practitioner_id: @current_user.id)
    @photo_report.save!
    render(json: @photo_report, status: :ok)
  end

  private

  def update_params
    params.permit(:approved, :redo_flag, :redo_reason, :redo_for_report_id)
  end

  def photo_report_params
    #Modify to allow for no photo submission if opt out options are given
    if (params[:photo_was_skipped] == true)
      params.require([:date, :why_photo_was_skipped])
    else
      params.require([:date, :photo_url])
    end

    params.permit(:date, :back_submission, :photo_url, :captured_at, :why_photo_was_skipped, :photo_was_skipped)
  end
end
