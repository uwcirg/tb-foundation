class DailyReportSerializer < ActiveModel::Serializer
  attributes :id, :date, :user_id, :photo_url, :medication_was_taken, :symptoms, :taken_at, :updated_at, :doing_okay, :photo_was_required, :created_offline, :status
  attribute :nausea_rating, if: -> { !object.symptom_report.nil? && !object.symptom_report.nausea_rating.nil? }
  attribute :photo_details, if: -> { !object.photo_report.nil? }
  attribute :why_medication_not_taken, if: -> { !object.medication_report.nil? && !object.medication_report.why_medication_not_taken.nil? }
  attribute :doing_okay_reason, if: -> {!object.doing_okay_reason.nil?}

  #Eventually would be good to show that symptom reprot has not been submitted if screen not completed, would break calendar page for now
  #attribute :symptoms, if: -> { !object.symptom_report.nil? }

  def photo_url
    object.get_photo
  end

  def photo_details
    return ({ file_name: object.photo_report.photo_url, approval_status: object.photo_report.approved })
  end

  def symptoms
    object.symptom_report.nil? ? [] : object.symptom_report.reported_symptoms
  end

  def medication_was_taken
    object.medication_report.nil? ? false : object.medication_report.medication_was_taken
  end

  def taken_at
    object.medication_report.nil? ? nil : object.medication_report.datetime_taken
  end

  def nausea_rating
    object.symptom_report.nil? ? nil : object.symptom_report.nausea_rating
  end

  def photo_was_required
    object.check_photo_day
  end

  def why_medication_not_taken
    object.medication_report.why_medication_not_taken
  end

  def status

    photo_day = object.check_photo_day
    return {
      medication_report: !object.medication_report.nil?,
      symptom_report: !object.symptom_report.nil?,
      photo_report: !object.photo_report.nil?,
      complete: !object.medication_report.nil? && !object.symptom_report.nil? && (!photo_day || !object.photo_report.nil?),
    }
  end
  
end
