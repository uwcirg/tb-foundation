class PatientStatsWorker
    include Sidekiq::Worker

    def perform(user_id)
        PatientInformation.find_by(patient_id: user_id).update_patient_stats
    end
    
  end