class PatientSerializer < ActiveModel::Serializer
    
    attributes :id, :full_name, :adherence
    attribute :daily_reports, if: -> { @instance_options[:include_daily_reports].present?}
    attribute :symptom_summary, if: -> { @instance_options[:include_symptom_summary].present?}
    attribute :number_missing_reports, if: -> { @instance_options[:include_missing_reports].present?}

    def full_name
        return("#{object.given_name} #{object.family_name}")
    end

    def symptom_summary
        object.weekly_symptom_summary
    end

    def number_missing_reports
        object.number_reports_past_week
    end

end