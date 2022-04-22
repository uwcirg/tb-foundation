require "securerandom"

class Patient < User
  include PhotoSchedule
  include SeedPatient
  include PatientSQL

  belongs_to :organization

  has_many :milestones, :foreign_key => :user_id
  has_many :daily_reports, :foreign_key => :user_id
  has_many :photo_reports, :foreign_key => :user_id
  has_many :medication_reports, :foreign_key => :user_id
  has_many :symptom_reports, :foreign_key => :user_id
  has_many :patient_notes
  has_many :education_message_statuses
  has_many :contact_tracing_surveys
  has_many :photo_days
  has_many :reminders
  has_many :resolutions

  has_one :daily_notification, :foreign_key => :user_id
  has_one :patient_information

  validates :family_name, presence: true
  validates :given_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
  validates :treatment_start, presence: true

  after_create :create_private_message_channel, :create_resolutions, :generate_photo_schedule, :add_treatment_end_date
  after_commit :create_patient_information_entry, on: :create

  scope :active, -> { where(:status => ("Active")) }
  scope :pending, -> { where(:status => ("Pending")) }
  scope :archived, -> { where(:status => ("Archived")) }
  scope :had_symptom_last_week, -> { where(id: DailyReport.symptoms_last_week.select(:user_id)) }
  scope :non_test, -> { where("organization_id > 0") }
  scope :requested_test_not_submitted, ->(date) { joins(:photo_days).where(photo_days: { date: date }).where.not(id: PhotoReport.where(date: date).select(:patient_id)) }
  scope :has_not_reported_in_more_than_three_days, -> { where.not(id: DailyReport.where("created_at >= ?", DateTime.now - 3.days).select(:user_id)) }

  def symptom_summary_by_days(days)
    sql = ActiveRecord::Base.sanitize_sql [SYMPTOM_SUMMARY, { user_id: self.id, num_days: days }]
    ActiveRecord::Base.connection.exec_query(sql).to_a[0]
  end

  def create_private_message_channel
    channel = self.channels.create!(title: self.full_name, is_private: true, category: "Patient")
  end

  def create_resolutions
    kinds = ["MissedMedication", "Symptom", "MissedPhoto", "NeedSupport","General"]
    kinds.each do |kind|
      resolution = self.resolutions.create!(practitioner: self.organization.practitioners.first, kind: kind, resolved_at: self.treatment_start)
    end
  end

  def generate_photo_schedule
    generate_schedule(self)
  end

  def photo_day_override
    puts("Generating Override Schedule")
    generate_schedule(self, false)
  end

  #Requires an ISO time ( Not DateTime )
  def update_daily_notification(time)
    if (self.daily_notification.nil?)
      self.create_daily_notification!(time: time, active: true, user: self)
    else
      self.daily_notification.update!(time: time)
    end

    return self.daily_notification
  end

  def disable_daily_notification
    self.daily_notification.update!(active: false) unless self.daily_notification.nil?
  end

  def symptom_summary
    hash = {}
    self.daily_reports.unresolved_symptoms.each do |report|
      hash["#{report.date}"] = report.symptom_report.reported_symptoms
    end
    return hash
  end

  def last_medication_resolution
    res = self.resolutions.where(kind: "MissedMedication").first
    if (res.nil?)
      return self.treatment_start
    end
    return self.resolutions.where(kind: "MissedMedication").first.updated_at
  end

  def has_missed_report
    last_res = self.last_medication_resolution
    days = ((DateTime.current - 1).to_date - last_res.to_date).to_i
    number_since = self.daily_reports.where("date > ?", last_res).count
    return(days > number_since)
  end

  #@TODO Refactor this redudant code for different types of resolutions - normalize in the front end so it uses the same resolution types
  def resolve_symptoms(practitioner_id)
    self.resolutions.create!(kind: "Symptom", practitioner_id: practitioner_id, resolved_at: DateTime.now)
  end

  def resolve_missing_report(practitioner_id, resolution_time = DateTime.now)
    self.resolutions.create!(kind: "MissedMedication", practitioner_id: practitioner_id, resolved_at: resolution_time)
  end

  def resolve_support_request(practitioner_id, resolution_time = DateTime.now)
    self.resolutions.create!(kind: "NeedSupport", practitioner_id: practitioner_id, resolved_at: resolution_time)
  end

  def formatted_reports
    hash = {}
    DailyReport.where(user_id: self.id).includes(:photo_report, :symptom_report, :medication_report).order("date DESC").each do |report|
      serialization = ActiveModelSerializers::SerializableResource.new(report)
      hash["#{report["date"]}"] = serialization
    end
    return hash
  end

  def current_streak
    self.patient_information.medication_streak
  end

  def missed_days
    return DailyReport.user_missed_days(self)
  end

  def feeling_healthy_days
    return self.daily_reports.where(doing_okay: true).count()
  end

  def photo_schedule
    self.photo_days.pluck(:date)
  end

  def reporting_status
    hash = {}
    today_report = self.daily_reports.find_by(date: localized_date)
    yesterday_report = self.daily_reports.find_by(date: localized_date)

    if (today_report.nil?)
      hash["today"] = { reported: false,
                        photo_required: self.photo_days.where(date: localized_date).exists? }
    else
      hash["today"] = {
        reported: !today_report.nil?,
        medication_taken: today_report.medication_was_taken,
        photo: today_report.photo_submitted,
        photo_required: self.photo_days.where(date: localized_date).exists?,
        number_symptoms: today_report.symptom_report.nil? ? 0 : today_report.symptom_report.number_symptoms,
      }
    end

    return hash
  end

  def last_symptoms
    list = []
    get_date = true
    date = nil
    self.symptom_reports.includes(:daily_report).where(daily_report: DailyReport.unresolved_symptoms.order("date DESC")).each do |symptom_report|
      if (get_date)
        date = symptom_report.daily_report.date
        get_date = false
      end
      to_add = symptom_report.reported_symptoms - list
      list = list + to_add
    end
    { symptomList: list, date: date }
  end

  def last_missed_day
    days = self.missed_days.first["date"] rescue nil
  end

  def has_reported_today(datetime = localized_date)
    self.daily_reports.where(date: datetime.to_date).exists?
  end

  def support_requests
    self.daily_reports.joins(:resolutions).where(id: DailyReport.unresolved_support_request).where("resolutions.patient_id = #{self.id}", "daily_reports.updated_at > resolutions.created_at").distinct
  end

  def days_in_treatment
    return (localized_date - self.treatment_start.to_date).to_i + 1
  end

  def number_of_days_with_photo_report
    return self.daily_reports.has_photo.count
  end

  def weeks_in_treatment
    (localized_date - self.treatment_start.beginning_of_week(start_day = :monday).to_date).to_i / 7
  end

  def percentage_complete
    return (self.days_in_treatment.to_f / 180).round(2)
  end

  def add_photo_day(date = localized_date)
    if (!self.photo_days.where(date: date).exists?)
      self.photo_days.create!(date: date)
    end
  end

  def reset_password
    temporary_password = SecureRandom.hex(10).upcase[0, 5]
    self.update_password(temporary_password, true)
    return temporary_password
  end

  def add_treatment_end_date
    if (self.treatment_end_date.nil?)
      self.update!(treatment_end_date: (self.treatment_start + 180.days).to_date)
    end
  end

  def has_forced_password_change
    self.has_temp_password && self.status != "Pending"
  end

  def update_number_of_missed_reporting_reminders_sent(new_number)
    self.patient_information.update!(reminders_since_last_report: new_number)
  end

  def number_of_photo_requests
    PhotoDay.where(patient_id: self.id).where("date < ? ", localized_date).count
  end

  def activate(time = Time.now)
    self.patient_information.update!(datetime_patient_activated: time)
  end

  def had_symptom_in_past_week?
    self.daily_reports.last_week.has_symptoms.exists?
  end

  def had_severe_symptom_in_past_week?
    self.daily_reports.last_week.has_severe_symptoms.exists?
  end

  def negative_photo_in_past_week?
    self.photo_days.missed_or_negative_in_past_week.exists?
  end

  def number_of_conclusive_photos
    self.photo_reports.has_daily_report.conclusive.count
  end

  def adherence
    self.patient_information.adherence
  end

  def update_stats_in_background
    ::PatientStatsWorker.perform_async(false, self.id)
  end

  def archived?
    return self.status == "Archived"
  end

  def back_submission_ratio
    total_number_of_reports = self.daily_reports.count.to_f
    return 0 unless total_number_of_reports > 0 #Prevent NaN result from zero division
    return (self.daily_reports.where("date < (created_at at time zone ?)::date", self.time_zone).count.to_f / total_number_of_reports).round(2)
  end

  def last_photo_request_status
    # Be sure to test in case of new patient where they do not have any previous requests
    request = self.photo_days.where("date < ?", self.localized_date).order("date DESC").first
    submitted = nil
    if (!request.nil?)
      submitted = self.photo_reports.where("daily_report_id is not null").find_by(date: request.date)
    end

    return {
             date_of_request: request.nil? ? 0 : request.date,
             photo_was_submitted: !submitted.nil? && submitted.has_photo?,
           }
  end

  def send_redo_notification
    I18n.with_locale(self.locale) do
      self.send_push_to_user(I18n.t("redo_photo.title"), I18n.t("redo_photo.body"), "/redo-photo", "RedoPhoto")
    end
  end

  def send_medication_reminder
    I18n.with_locale(self.locale) do
      self.send_push_to_user(I18n.t("medication_reminder"), I18n.t("medication_reminder_body"), "/home", "MedicationReminder", [
        {
          action: "good",
          title: "👍 Si",
        },
        {
          action: "issue",
          title: "💬 No",
        },
      ])
    end
  end

  def number_of_messages_from_assistant
    self.channels.first.messages.where(user_id: Practitioner.where(organization_id: self.organization_id)).count
  end

  def first_photo_id
    self.photo_reports.first.id
  end

  def latest_photo_submission
    PhotoReport.where(user_id: self.id).where("created_at IS NOT NULL").order("created_at DESC").first
  end

  def last_contacted
    self.channels.find_by(is_private: true).last_message_time
  end

  def priority
    self.patient_information.priority
  end

  def last_general_resolution
    last_resolution = self.resolutions.General.last
    last_resolution.nil? ? nil : last_resolution.resolved_at
  end

  def daily_reports_since_last_resolution
    self.daily_reports.last(10)
  end

  private

  def create_patient_information_entry
    if (!PatientInformation.where(patient_id: self.id).exists?)
      self.create_patient_information!(patient_id: self.id, datetime_patient_added: Time.current - 30.minutes, datetime_patient_activated: Rails.env.test? ? Time.current : nil)
    end
  end
end
