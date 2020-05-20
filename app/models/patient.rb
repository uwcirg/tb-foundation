class Patient < User
  has_one :practitioner
  #has_one :daily_notification

  has_many :milestones, :foreign_key=> :user_id
  has_many :daily_reports, :foreign_key=> :user_id
  has_many :photo_reports, :foreign_key=> :user_id
  has_many :medication_reports, :foreign_key=> :user_id
  has_many :symptom_reports, :foreign_key=> :user_id
  has_one :daily_notification, :foreign_key=> :user_id

  #validates :user_type, value:
  validates :family_name, presence: true
  validates :given_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{9,15}\z/, message: "Only allows a string representation of a digit (9-15 char long)" }
  validates :treatment_start, presence: true
  validates :practitioner_id, presence: true

  after_create :create_private_message_channel, :create_milestone
  before_create :generate_medication_schedule

  def create_private_message_channel
    channel = self.channels.create!(title: self.full_name, is_private: true)
    channel.messages.create!(body: "Hola. Buenas dias.", user_id: self.practitioner_id)
  end

  def as_fhir_json(*args)
    if (!self.daily_notification.nil?)
      reminderTime = self.daily_notification.formatted_time
    else
      reminderTime = ""
    end

    return {
             id: id,
             givenName: given_name,
             familyName: family_name,
             identifier: [
               { value: id, use: "official" },
               { value: "username", use: "messageboard" },
             ],
             phoneNumber: phone_number,
             treatmentStart: treatment_start,
             medicationSchedule: medication_schedule,
             managingOrganization: managing_organization,
             reminderTime: reminderTime,
             lastReport: latest_report,

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
    puts("Generating Medication Schedule")
    self.medication_schedule = list_of_lists.as_json
  end

  #Make Patients Need Photo Everyday
  def photo_day_override
    i = 0
    list_of_lists = []

    while i < 26
      n = 0
      list = [1, 2, 3, 4, 5, 6, 7]
      list_of_lists.append(list)
      i += 1
    end
    puts("Overriding Medication Schedule For Testing")
    self.update(medication_schedule: list_of_lists.as_json)
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

  def create_milestone
     self.milestones.create(title: "Treatment Start",datetime: self.treatment_start,all_day: true)
     self.milestones.create(title: "One Month of Treatment",datetime: self.treatment_start + 1.month ,all_day: true)
     self.milestones.create(title: "End of Treatment",datetime: self.treatment_start + 6.month ,all_day: true)
  end

  def seed_test_reports
    (treatment_start.to_date..DateTime.current.to_date).each do |day|
      should_report = [true, true, true, true, false].sample

      if(should_report)
        create_seed_report(day)
      end

    end
  end

  def create_seed_report(day)
    datetime = DateTime.new(day.year, day.month, day.day, 4, 5, 6, "-04:00")

    med_report = MedicationReport.create!(user_id: self.id, medication_was_taken: [true, true, true, false].sample, datetime_taken: datetime)
    symptom_report = SymptomReport.create!(
      user_id: self.id,
      nausea: [true, false].sample,
      nausea_rating: [true, false].sample,
      redness: [true, false].sample,
      hives: [true, false].sample,
      fever: [true, false].sample,
      appetite_loss: [true, false].sample,
      blurred_vision: [true, false].sample,
      sore_belly: [true, false].sample,
      other: "Other text would go here!",
    )

    new_report = DailyReport.create(date: day, user_id: self.id)

    new_report.medication_report = med_report
    new_report.symptom_report = symptom_report
    new_report.save
  end

end
