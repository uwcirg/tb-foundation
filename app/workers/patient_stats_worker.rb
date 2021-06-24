class PatientStatsWorker
  include Sidekiq::Worker

  def perform(update_all_patients, patient_id=nil)
    if (update_all_patients)
      update_all
    else
      PatientInformation.find_by(patient_id: patient_id).update_patient_stats
    end
  end

  private

  def update_all
    PatientInformation.all.each do |pi|
      pi.update_patient_stats
    end
  end
end
