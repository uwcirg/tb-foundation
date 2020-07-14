class DailyReport < ApplicationRecord

  include PatientSQL

  belongs_to :patient, :foreign_key => :user_id
  has_many :resolutions, through: :patient
  has_one :medication_report
  has_one :symptom_report
  has_one :photo_report

  validates :medication_report, presence: true
  validates :symptom_report, presence: true
  validates :date, presence: true

  scope :today, -> { where(:date => (Time.now.to_date)) }
  scope :last_week, -> { where("date > ?", Time.now - 1.week) }
  scope :two_days, -> { where("date > ?", Time.now - 10.days) }
  scope :was_taken, -> { joins(:medication_report).where(medication_reports: { medication_was_taken: true }) }
  scope :unresolved_symptoms, -> { joins(:resolutions).where(:symptom_report => SymptomReport.has_symptom, "resolutions.id": Resolution.last_symptom_from_user).where("daily_reports.updated_at > resolutions.resolved_at") }
  scope :since_last_missing_resolution, -> { joins(:resolutions).where("resolutions.id": Resolution.last_medication_from_user).where("daily_reports.created_at > resolutions.resolved_at") }

  def self.user_missed_days(user_id)
    sql = sanitize_sql [MISSED_DAYS, { user_id: user_id }]
    # result_value = connection.select_value(sql)
    return ActiveRecord::Base.connection.exec_query(sql)
  end

  def self.user_streak_days(user_id)
    sql = sanitize_sql [USER_STREAK_DAYS_SQL, { user_id: user_id }]
    result_value = connection.select_value(sql)
    Integer(result_value) rescue nil
  end

  def limit_one
    if self.daily_reports.today.count == 1
      errors.add(:base, "Exceeds daily limit")
    end
  end

  def get_photo
    if (!self.photo_report.nil?)
      return self.photo_report.get_url
    end
    return nil
  end

  def get_photo_ref
    if (!self.photo_report.nil?)
      return self.photo_report.photo_url
    else
      return nil
    end
  end

  def symptom_summary
    return symptom_report.as_json
  end

end
