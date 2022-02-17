class PhotoReport < ApplicationRecord
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
