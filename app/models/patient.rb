class Patient < User

    has_one :practitioner

    #validates :user_type, value: 
    validates :family_name, presence: true
    validates :given_name, presence: true
    validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
    validates :treatment_start, presence: true
    validates :practitioner_id, presence: true

    after_create :create_private_message_channel
    before_create :generate_medication_schedule

    def create_private_message_channel
        channel = self.channels.create!(title: "Coordinator Chat #{self.id} ", is_private:true);
        channel.messages.create!(body: "Welcome, this is the first TEST message!",user_id: self.id);
    end

  #Algorithim to Randomize day that Patients Have to Report Their Test Strips
  def generate_medication_schedule
    i = 0
    list_of_lists = []

    #26 weeks of treatment
    while i < 26 do
        n = 0
        list = []

        #Account for changing frequency after 2 months
        if i < 8
          mod = 0
        else
          mod = 1
        end

        #Can vary from 1 to 3 Times a week
        while n < rand(2-mod..3-mod) do
          day = -1
          until day != -1 && !(list.include? day) do
            day = rand(1..5)
          end
            list.append(day)
            n += 1
        end

        list_of_lists.append(list)
        i+= 1
    end

      self.medication_schedule = list_of_lists.as_json
end


    
  end