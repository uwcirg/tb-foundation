class Patient < User

    #validates :user_type, value: 
    validates :family_name, presence: true
    validates :given_name, presence: true
    validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{10,15}\z/, message: "Only allows a string representation of a digit (3-10 char long)" }
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