class PatientSerializer < ActiveModel::Serializer
    
    attributes :given_name, :family_name, :id, :full_name, :adherence, :percentage_complete, :days_in_treatment, :last_report, :treatment_start, :medication_schedule, :current_streak, :phone_number
    attribute :daily_reports,  if: -> {@instance_options[:all_details].present? || @instance_options[:include_daily_reports].present? }
    attribute :feeling_healthy_days,  if: -> {@instance_options[:all_details].present?}
    attribute :symptom_summary, if: -> { @instance_options[:include_symptom_summary].present?}
    attribute :number_missing_reports, if: -> { @instance_options[:include_missing_reports].present?}

    def full_name
        return("#{object.given_name} #{object.family_name}")
    end

    def symptom_summary
        object.daily_reports
    end

end