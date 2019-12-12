class User < ApplicationRecord

    enum language: { en: 0, es: 1 }

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