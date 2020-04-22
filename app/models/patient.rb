class Patient < User
  has_one :practitioner
  #has_one :daily_notification


  #validates :user_type, value:
  validates :family_name, presence: true
  validates :given_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
  validates :treatment_start, presence: true
  validates :practitioner_id, presence: true

  after_create :create_private_message_channel
  before_create :generate_medication_schedule

  def create_private_message_channel
    channel = self.channels.create!(title: "Coordinator Chat #{self.id} ", is_private: true)
    channel.messages.create!(body: "Welcome, this is the first TEST message!", user_id: self.id)
  end


  def as_fhir_json(*args)

    if(!self.daily_notification.nil?)
      reminderTime = self.daily_notification.formatted_time
    else
      reminderTime = ""
    end

    return {
      id: id,
      givenName: given_name,
      familyName: family_name,
      identifier: [
          {value: id,use: "official"},
          {value: "test",use: "messageboard"}
      ],
      phoneNumber: phone_number,
      treatmentStart: treatment_start,
      medicationSchedule: medication_schedule,
      managingOrganization: managing_organization,
      reminderTime: reminderTime,
      lastReport: latest_report

    }
  end

  #Algorithim to Randomize day that Patients Have to Report Their Test Strips
  def generate_medication_schedule
    i = 0
    list_of_lists = []

    #26 weeks of treatment
    while i < 26
      n = 0
      list = []

      #Account for changing frequency after 2 months
      if i < 8
        mod = 0
      else
        mod = 1
      end

      #Can vary from 1 to 3 Times a week
      while n < rand(2 - mod..3 - mod)
        day = -1
        until day != -1 && !(list.include? day)
          day = rand(1..5)
        end
        list.append(day)
        n += 1
      end

      list_of_lists.append(list)
      i += 1
    end
    puts("Med Gen")
    self.medication_schedule = list_of_lists.as_json
  end

  def photo_day_override
    i = 0
    list_of_lists = []

    #26 weeks of treatment
    while i < 26
      n = 0
      list = [1,2,3,4,5,6,7]
      list_of_lists.append(list)
      i += 1
    end
    puts("OVERRIDE")
    self.update(medication_schedule: list_of_lists.as_json)
  end

  def test_method
    puts("#{self.given_name} #{self.family_name}")
  end

  def create_daily_notification
    newNotification = DailyNotification.create!(time: "01:05-04:00", active: true, user: self)
    self.daily_notification = newNotification
  end

  def proper_reports
    hash = {}

    self.daily_reports.each do |report|
      hash["#{report.date}"] = report
    end

    return hash
  end

  def latest_report
    self.daily_reports.last
  end

end
