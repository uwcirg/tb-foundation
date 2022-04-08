class PhotoReport < ApplicationRecord

  include Paginatable::Model

  has_one :redo_new_report, class_name: "PhotoReport", :foreign_key => :redo_for_report_id
  belongs_to :redo_original_report, class_name: "PhotoReport", :foreign_key => :redo_for_report_id, optional: true

  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key => :user_id
  has_one :organization, :through => :patient

  has_many :photo_reviews

  scope :first_report_per_user, -> {has_daily_report.group(:user_id).minimum(:id)}

  scope :has_daily_report, -> { where("daily_report_id IS NOT NULL") }
  scope :reviewable, -> { where(patient: Patient.non_test).has_daily_report }
  scope :conclusive, -> { where(approved: true) }

  scope :patient_id, -> p_id { where(user_id: p_id )}

  scope :unreviewed, -> { joins("LEFT JOIN photo_reviews on photo_reviews.photo_report_id = photo_reports.id").where("photo_reviews.id IS NULL")}
  scope :unreviewed_by, -> user_id {
    sanitized = ActiveRecord::Base.sanitize_sql_array(["LEFT JOIN photo_reviews on photo_reviews.photo_report_id = photo_reports.id AND photo_reviews.bio_engineer_id = ?", user_id])
    joins(sanitized).where("photo_reviews.id IS NULL")
  }

  scope :not_skipped, -> {where("photo_url is not null")}

  def self.policy_class
    PhotoReportPolicy
  end

  def assigned_practitioner
    return self.user.practitioner_id
  end

  def approve(id)
    self.update(approved: true, practitioner_id: id, approval_timestamp: DateTime.now())
    self.save
  end

  def deny(id)
    self.update(approved: false, practitioner_id: id, approval_timestamp: DateTime.now())
    self.save
  end

  def get_url
    if (self.photo_url.nil?)
      temp_url = nil
    else
      signer = Aws::S3::Presigner.new
      #Temp url will default to 15 minute expiry time
      temp_url = signer.presigned_url(:get_object, bucket: "patient-test-photos", key: photo_url)
    end

    return temp_url
  end

  def has_photo?
    return !self.photo_url.nil?
  end

  def send_redo_notification
    if (is_latest_submission_for_patient?)
      self.patient.send_redo_notification
    end
  end

  def is_latest_submission_for_patient?
    latest = self.patient.latest_photo_submission
    !latest.nil? && self.id == self.patient.latest_photo_submission.id
  end

  private

  def update_patient_stats
    self.patient.update_stats_in_background
  end

end
