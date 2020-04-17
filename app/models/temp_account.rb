class TempAccount < ApplicationRecord

    validates :phone_number, presence: true, uniqueness: true
    validates :given_name, presence: true
    validates :family_name, presence: true

    def as_fhir_json(*args)
    
        return {
          givenName: given_name,
          familyName: family_name,
          phoneNumber: phone_number,
          treatmentStart: treatment_start,
    
        }
      end

end