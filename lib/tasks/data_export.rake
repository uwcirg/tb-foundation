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
      columns = %w(redcap_id created_at uuid treatment_start)
      csv << columns
      Participant.where(uuid: filtered_patients.pluck(:uuid)).each do |report|
      rc_id = Participant.redcap_map[report.uuid.to_sym]
      values = [rc_id, *report.attributes.slice(*columns).values]
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

  desc "Grouped symptom summary export"
  task calc_symptom_data: :environment do
    reports_per_participant = {} 
    had_symptoms_per_participant = {}
    
    Participant.redcap_map.values.uniq.map{|v| 
      reports_per_participant[v] = 0
      had_symptoms_per_participant[v] = 0

    }

    
    SymptomReport.where(id: SymptomReport.non_test.group(:participant_id,:timestamp).maximum(:id).values ).group(:participant_id).count.map{|e| 
      rc_id = Participant.redcap_map[e[0].to_sym]
      reports_per_participant[rc_id] += e[1]
    }

    SymptomReport.has_symptoms.where(id: SymptomReport.non_test.group(:participant_id,:timestamp).maximum(:id).values ).group(:participant_id).count.map{|ee|
      rc_id = Participant.redcap_map[ee[0].to_sym]
      had_symptoms_per_participant[rc_id] += ee[1]
    }



    print reports_per_participant.values
    puts ""
    print had_symptoms_per_participant.values

    puts ""


    puts("Reports")
    Analysis.calc_mean_and_sd(reports_per_participant.values)

    puts("Reports with symptoms")
    Analysis.calc_mean_and_sd(had_symptoms_per_participant.values)

  end

end
