class PhotoReport < ApplicationRecord

  after_update_commit :send_redo_notification, if: :flagged_for_redo?
  
  has_one :redo_new_report , class_name: 'PhotoReport', :foreign_key => :redo_for_report_id
  belongs_to :redo_original_report, class_name: 'PhotoReport', :foreign_key => :redo_for_report_id, optional: true
  
  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key => :user_id
  has_one :organization, :through => :patient

  has_many :photo_reviews

  scope :has_daily_report, -> { where("daily_report_id IS NOT NULL") }
  scope :reviewable, -> {where(patient: Patient.non_test).has_daily_report}
  scope :conclusive, -> { where(approved: true) }

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
      self.patient.send_redo_notification
  end

  private

  def flagged_for_redo?
    # !self.daily_report_id.nil? Prevents notificaiton from being sent when old report is unlinked from daily report for today
    self.redo_flag && !self.daily_report_id.nil?
  end

  def update_patient_stats
    self.patient.update_stats_in_background
  end
end
