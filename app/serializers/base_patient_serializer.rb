class BasePatientSerializer < ActiveModel::Serializer
    
    attribute :treatment_outcome, if: -> { object.archived?}

    def treatment_outcome
        {
        treatment_outcome: object.patient_information.treatment_outcome,
        app_end_date: object.patient_information.app_end_date 
        }
    end
end