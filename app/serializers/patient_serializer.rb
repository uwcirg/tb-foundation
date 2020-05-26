class PatientSerializer < ActiveModel::Serializer
    
    attributes :id, :full_name
    attribute :daily_reports, if: -> { @instance_options[:with_reports].present?}
    attribute :symptom_summary, if: -> { @instance_options[:include_symptom_summary].present?}

    def full_name
        return("#{object.given_name} #{object.family_name}")
    end

    def symptom_summary
        object.weekly_symptom_summary
    end

end