class SevereSymptomsAlertWorker
  include Sidekiq::Worker

  def perform(organization_id)
    Organization.find(organization_id).practitioners.each do |practitioner|
      NotifyUser.new(practitioner).severe_symptom_alert
    end
  end
end
