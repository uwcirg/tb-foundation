class DailyReport < ApplicationRecord
  include PatientSQL

  belongs_to :patient, :foreign_key => :user_id
  has_many :resolutions, through: :patient
  has_one :medication_report
  has_one :symptom_report
  has_one :photo_report

  validates :date, presence: true
  validate :limit_one_report_per_day, on: :create

  after_commit :update_reminders_since_last_report, :update_patient_stats

  scope :patient_id, ->patient_id { where(user_id: patient_id) }
  scope :from_active_patient, -> { where(patient: Patient.non_test.active) }
  scope :within_date_range, ->(date_range) { where(date: date_range) }
  scope :between, ->(start_date, end_date) { where("daily_reports.date >= ? AND daily_reports.date <= ?", start_date, end_date) }
  scope :today, -> { where(:date => (LocalizedDate.now_in_ar)) }
  scope :last_week, -> { where("daily_reports.date > ?", LocalizedDate.now_in_ar - 1.week) }
  scope :symptoms_last_week, -> { last_week.where(:symptom_report => SymptomReport.has_symptom) }
  scope :active_patient, -> { where(:patient => Patient.active) }
  scope :was_taken, -> { joins(:medication_report).where(medication_reports: { medication_was_taken: true }).distinct }
  scope :before_today, -> { where("date < ?", LocalizedDate.now_in_ar.to_date) }
  scope :unresolved_symptoms, -> { active_patient.joins(:resolutions).where(:symptom_report => SymptomReport.has_symptom, "resolutions.id": Resolution.last_symptom_from_user).where("daily_reports.updated_at > resolutions.resolved_at") }
  scope :since_last_missing_resolution, -> { active_patient.joins(:resolutions).where("resolutions.id": Resolution.last_medication_from_user).where("daily_reports.date > resolutions.resolved_at") }
  scope :has_symptoms, -> { active_patient.joins(:symptom_report).where(:symptom_report => SymptomReport.has_symptom) }
  scope :has_severe_symptoms, -> { active_patient.joins(:symptom_report).where(:symptom_report => SymptomReport.has_severe_symptom) }
  scope :has_photo, -> { joins(:photo_report).where("photo_reports.photo_url IS NOT NULL") }
  scope :unresolved_support_request, -> { active_patient.joins(:resolutions).where("resolutions.id": Resolution.last_support_request, "daily_reports.doing_okay": false).where("daily_reports.created_at > resolutions.resolved_at") }
  scope :photo_missing, -> { joins(:photo_report).where("photo_reports.id = ?", nil) }
  scope :medication_was_not_taken, -> { joins(:medication_report).where(medication_reports: { medication_was_taken: false }).distinct }

  scope :unresolved, -> { active_patient.joins(:resolutions).where("resolutions.id": Resolution.last_general_from_user).where("daily_reports.updated_at >= date(resolutions.resolved_at) or daily_reports.updated_at > resolutions.resolved_at") }

  def self.policy_class
    PatientRecordPolicy
  end

  def limit_one_report_per_day
    if self.patient.daily_reports.where(date: self.date).count > 0
      errors.add(:base, "Only one report allowed daily. Edit the report instead.")
    end
  end

  def self.create_if_not_exists(patient_id, date)
    report = DailyReport.where(user_id: patient_id, date: date)
    if report.exists?
      return report.first
    end

    return DailyReport.create!(user_id: patient_id, date: date, was_one_step: true)
  end

  def self.user_missed_days(user_id)
    sql = sanitize_sql [MISSED_DAYS, { user_id: user_id }]
    # result_value = connection.select_value(sql)
    return ActiveRecord::Base.connection.exec_query(sql) rescue nil
  end

  def self.user_streak_days(user_id)
    sql = sanitize_sql [USER_STREAK_DAYS_SQL, { user_id: user_id }]
    result_value = connection.select_value(sql)
    Integer(result_value) rescue nil
  end

  def get_photo
    if (!self.photo_report.nil?)
      return self.photo_report.get_url
    end
    return nil
  end

  def check_photo_day
    self.patient.photo_days.where(date: self.date).exists?
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

  def medication_was_taken
    if (medication_report.nil?)
      return false
    end

    return medication_report.medication_was_taken
  end

  def photo_submitted
    return !photo_report.nil?
  end

  #Determine if report was created afer the day it was requested on ( reports are requested daily )
  def number_of_days_after_request
    (self.created_at.in_time_zone(self.patient.time_zone).to_date - self.date).to_i
  end

  private

  def update_reminders_since_last_report
    self.patient.patient_information.update!(reminders_since_last_report: 0)
  end

  def update_patient_stats
    self.patient.update_stats_in_background
  end
end
