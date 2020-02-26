class Patient < User

    #validates :user_type, value: 
    validates :family_name, presence: true
    validates :given_name, presence: true
    validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
    validates :treatment_start, presence: true

    after_create :create_private_message_channel

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

    def create_private_message_channel
        channel = self.channels.create!(title: "Coordinator Chat #{self.id} ", is_private:true);
        channel.messages.create!(body: "Welcome, this is the first TEST message!",user_id: self.id);
    end


    
  end