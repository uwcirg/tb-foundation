require 'csv'

namespace :data_export do
  desc "Exports all report types to csv from participants that have a study ID (non-test accounts)"
  task export_paper_csv: :environment do

    filtered_patients = Participant.non_test

    CSV.open("tmp/fixed_csv/strip_reports.csv", "wb") do |csv|
      columns = %w(participant_id timestamp created_at url_photo status resolution_uuid)
      csv << columns
      StripReport.where(participant: filtered_patients).each do |report|
      values = report.attributes.slice(*columns).values
        csv << values
      end
    end
  
    CSV.open("tmp/fixed_csv/med_reports.csv", "wb") do |csv|
      columns = %w(participant_id timestamp created_at not_taking_medication_reason resolution_uuid)
      csv << columns
      MedicationReport.where(participant: filtered_patients).each do |report|
      values = report.attributes.slice(*columns).values
        csv << values
      end
    end
  
    CSV.open("tmp/fixed_csv/symptom_reports.csv", "wb") do |csv|
      columns = SymptomReport.attribute_names
      csv << columns
      SymptomReport.where(participant: filtered_patients).each do |report|
      values = report.attributes.slice(*columns).values
        csv << values
      end
    end

    CSV.open("tmp/fixed_csv/participants.csv", "wb") do |csv|
      columns = %w(created_at uuid treatment_start)
      csv << columns
      Participant.where(uuid: filtered_patients.pluck(:uuid)).each do |report|
      values = report.attributes.slice(*columns).values
        csv << values
      end
    end
  
    CSV.open("tmp/fixed_csv/resolutions.csv", "wb") do |csv|
      columns = %w(created_at timestamp note participant_uuid author_id)
      csv << columns
      Resolution.where(participant_uuid: filtered_patients.pluck(:uuid)).each do |report|
      values = report.attributes.slice(*columns).values
        csv << values
      end
    end



  end

end
