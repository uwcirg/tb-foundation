class Patient < User

    validates :family_name, presence: true
    validates :given_name, presence: true
    validates :phone_number, presence: true, uniqueness: true
    validates :treatment_start, presence: true

    def as_fhir_json(*args)
        {
          givenName: given_name,
          familyName: family_name,
          identifier: [
              {value: id,use: "official"},
              {value: "test",use: "messageboard"}
          ]
        
      }
      end
    
  end