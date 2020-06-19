class Patient < User

  #Medicaiton Schedules are defined in this file ./medication_scheudle.rb
  include PhotoSchedule
  include SeedPatient

  belongs_to :practitioner, :foreign_key => :practitioner_id
  has_many :milestones, :foreign_key => :user_id
  has_many :daily_reports, :foreign_key => :user_id
  has_many :photo_reports, :foreign_key => :user_id
  has_many :medication_reports, :foreign_key => :user_id
  has_many :symptom_reports, :foreign_key => :user_id
  has_one :daily_notification, :foreign_key => :user_id

  has_many :resolutions

  #validates :user_type, value:
  validates :family_name, presence: true
  validates :given_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
  validates :treatment_start, presence: true
  validates :practitioner_id, presence: true

  after_create :create_private_message_channel, :create_milestone, :create_resolutions
  before_create :generate_medication_schedule

  scope :active, -> { where(:active => (true)) }


  def create_private_message_channel
    channel = self.channels.create!(title: self.full_name, is_private: true)
    channel.messages.create!(body: "Hola. Buenas dias.", user_id: self.practitioner_id)
  end

  def create_resolutions
    kinds = ["MissedMedication", "Symptom", "MissedPhoto"]
    kinds.each do |kind|
      resolution = self.resolutions.create!(practitioner: self.practitioner, kind: kind, resolved_at: self.treatment_start)
    end
  end

  def generate_medication_schedule
    schedule = random_schedule
    puts("Generating Medication Schedule")
    self.medication_schedule = schedule.as_json
  end

  def photo_day_override
    schedule = every_day_schedule
    puts("Overriding Medication Schedule For Testing")
    self.update(medication_schedule: schedule.as_json)
  end

  def create_daily_notification
    newNotification = DailyNotification.create!(time: "01:05-04:00", active: true, user: self)
    self.daily_notification = newNotification
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

  def number_reports_past_week
    return (self.daily_reports.last_week.count)
  end

  def days_in_treatment
    days = (DateTime.current.to_date - self.treatment_start.to_date).to_i

    if (days > 0)
      return days + 1
    end

    return 1
  end

  def weeks_in_treatment
    return(days_in_treatment/7)
  end

  def adherence
    return (self.daily_reports.was_taken.count.to_f / self.days_in_treatment).round(2)
  end

  def percentage_complete
    return (self.days_in_treatment.to_f / 180).round(2)
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

  def resolve_symptoms
    self.resolutions.create!(kind: "Symptom", practitioner: self.practitioner, resolved_at: DateTime.now)
  end

  def resolve_missing_report
    self.resolutions.create!(kind: "MissedMedication", practitioner: self.practitioner, resolved_at: DateTime.now)
  end

  def formatted_reports
    hash = {}
    self.daily_reports.each do |report|
      serialization = ActiveModelSerializers::SerializableResource.new(report)
      hash["#{report["date"]}"] = serialization
    end
    return hash
  end

  def current_streak
      streak = DailyReport.user_streak_days(self)
  end

  def feeling_healthy_days
    return self.daily_reports.where(doing_okay: true).count();
  end

  def get_streak

      sql = "WITH report_dates AS (
        SELECT DISTINCT date
        FROM daily_reports
        WHERE user_id=3
        ),
        report_dates_groups AS (
        SELECT
          date,
          date::DATE - CAST(row_number() OVER (ORDER BY date) as INT) AS grp
        FROM report_dates
          )
        SELECT
          max(date) - min(date) + 1 AS length
        FROM report_dates_groups
        GROUP BY grp
        ORDER BY max(date) DESC
        LIMIT  1"

        tst = 'SELECT * FROM daily_reports'

        results = ActiveRecord::Base.connection.exec_query(sql)
        puts(results)
  end
end
