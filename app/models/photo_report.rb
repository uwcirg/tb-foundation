class PhotoReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key => :user_id
  after_commit :update_patient_stats

  has_many :code_applications
  has_many :photo_codes , :through => :code_applications

  scope :has_daily_report, -> { where("daily_report_id IS NOT NULL") }
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
      tempURL = nil
    else
      signer = Aws::S3::Presigner.new
      tempURL = signer.presigned_url(:get_object, bucket: "patient-test-photos", key: photo_url)
    end

    return tempURL
  end

  def pretty_json
    return {
             url: get_url,
           }
  end

  def has_photo?
    return !self.photo_url.nil?
  end

  private

  def update_patient_stats
    self.patient.update_stats_in_background
  end
end
