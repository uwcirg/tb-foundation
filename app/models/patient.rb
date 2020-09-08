class Patient < User

  #Medicaiton Schedules are defined in this file ./medication_scheudle.rb
  include PhotoSchedule
  include SeedPatient
  include PatientSQL

  belongs_to :organization

  has_many :milestones, :foreign_key => :user_id
  has_many :daily_reports, :foreign_key => :user_id
  has_many :photo_reports, :foreign_key => :user_id
  has_many :medication_reports, :foreign_key => :user_id
  has_many :symptom_reports, :foreign_key => :user_id
  has_many :resolutions
  has_many :patient_notes
  has_many :education_message_statuses
  has_many :photo_days
  has_many :reminders

  has_one :daily_notification, :foreign_key => :user_id
  has_one :contact_tracing

  #validates :user_type, value:
  validates :family_name, presence: true
  validates :given_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
  validates :treatment_start, presence: true

  after_create :create_private_message_channel, :create_milestone, :create_resolutions, :generate_photo_schedule

  scope :active, -> { where(:status => ("Active")) }
  scope :pending, -> { where(:status => ("Pending")) }
  scope :had_symptom_last_week, -> { where(id: DailyReport.symptoms_last_week.select(:user_id)) }

  def symptom_summary_by_days(days)
    sql = ActiveRecord::Base.sanitize_sql [SYMPTOM_SUMMARY, { user_id: self.id, num_days: days }]
    ActiveRecord::Base.connection.exec_query(sql).to_a[0]
  end

  def create_private_message_channel
    channel = self.channels.create!(title: self.full_name, is_private: true)
    #channel.messages.create!(body: "Hola. Buenas dias.", user_id: self.organization.practitioners.first.id)
  end

  def create_resolutions
    kinds = ["MissedMedication", "Symptom", "MissedPhoto", "NeedSupport"]
    kinds.each do |kind|
      resolution = self.resolutions.create!(practitioner: self.organization.practitioners.first, kind: kind, resolved_at: self.treatment_start)
    end
  end

  def generate_photo_schedule
    puts("Generating Photo Schedule")
    generate_schedule(self)
  end

  def photo_day_override
    puts("Generating Override Schedule")
    generate_schedule(self, false)
  end

  #Requires an ISO time ( Not DateTime )
  def update_daily_notification(time)
    if (self.daily_notification.nil?)
      new_notification = DailyNotification.create!(time: time, active: true, user: self)
      self.daily_notification = new_notification
    else
      self.daily_notification.update!(time: time)
    end
    return self.daily_notification
  end

  def disable_daily_notification
    self.daily_notification.update!(active: false)
  end

  def last_report
    self.daily_reports.last
  end

  def create_milestone
    self.milestones.create(title: "Treatment Start", datetime: self.treatment_start, all_day: true)
    self.milestones.create(title: "One Month of Treatment", datetime: self.treatment_start + 1.month, all_day: true)
    self.milestones.create(title: "End of Treatment", datetime: self.treatment_start + 6.month, all_day: true)
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
    streak = DailyReport.user_streak_days(self)
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
    today_report = self.daily_reports.find_by(date: Date.today)
    yesterday_report = self.daily_reports.find_by(date: Date.yesterday)

    if (today_report.nil?)
      hash["today"] = { reported: false,
                        photo_required: self.photo_days.where(date: Date.today).exists? }
    else
      hash["today"] = {
        reported: !today_report.nil?,
        medication_taken: today_report.medication_was_taken,
        photo: today_report.photo_submitted,
        photo_required: self.photo_days.where(date: Date.today).exists?,
        number_symptoms: today_report.symptom_report.number_symptoms,
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

  def has_reported_today
    self.daily_reports.today.exists?
  end

  def support_requests
    self.daily_reports.joins(:resolutions).where(id: DailyReport.unresolved_support_request).where("resolutions.patient_id = #{self.id}", "daily_reports.updated_at > resolutions.created_at").distinct
  end

  def days_in_treatment
    return (Date.today - self.treatment_start.to_date).to_i + 1
  end

  def number_of_treatments_taken
    return self.daily_reports.was_taken.count.to_f
  end

  def adherence
    #Is treatment start or has reported today
    days = days_in_treatment

    if(!has_reported_today && days_in_treatment > 1)
      days = days-1
    end
      
    return (number_of_treatments_taken.to_f / days.to_f)
  end

  def weeks_in_treatment
    (Date.today - self.treatment_start.beginning_of_week(start_day = :monday).to_date).to_i / 7
  end

  def percentage_complete
    return (self.days_in_treatment.to_f / 180).round(2)
  end

end
