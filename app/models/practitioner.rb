class Practitioner < User
  belongs_to :organization
  has_many :patients, through: :organization
  has_many :resolutions
  validates :type, inclusion: { in: ["Practitioner"] }
  validates :email, presence: true

  def get_photos
    #If you need more information from the DailyReport change this query to use DailyReport as the base, then join the other tables
    photos_needing_approval = PhotoReport.where(approved: nil).joins(:daily_report).joins(:patient).where(patient: self.patients )
    return(photos_needing_approval)
  end

  def get_historical_photos
    historical_photos = PhotoReport.where.not(approved: nil).joins(:daily_report).joins(:patient).where(patient: self.patients )
    return(process_photos(historical_photos))
  end

  def process_photos(photos)
    list = []
    photos.each do |report|
      list.push({ "url": report.get_url, "photo_id": report.id, "approved": report.approved })
    end

    return list
  end

  def missed_since_last_resolution

    #Daily reports where time > than last resolution, where patients are in the coordinators list of patients
    #Where reports are less than number of days since last resolution
    start = DateTime.now - 1.week
    stop = DateTime.now - 1.day
    list = (start..stop).to_a

    #.includes will join the tables so you have access to tall of the reports alrady
    hash = {}
    # self.patients.inincludes(:resolutions).where("resolutions.patient_id": self.patients, "resolutions.kind": "MissedMedication").each do |u|
    #     #puts(u.full_name)
    #     hash[u.id] = u.full_name
    # end

    self.patients.includes(:resolutions).each do |u|
      #puts(u.full_name)
      hash[u.id] = u.full_name
    end

    return(hash)

    #puts( DailyReport.where(patient: self.patients).where("updated_at > ?",DateTime.now - 1.days).count )

    #return self.patients.where(daily_reports: Dailyself.resolutions.find_by(kind: "MissedMedication").updated_at

    #rp = DailyReport.where(date: list)
    #list = @current_practitoner.patients.where.not(daily_reports: DailyReport.after().group("user_id").having('count(user_id) = 7'))
  end

  def patient_names
    hash = {}
    Patient.where(practitioner_id: self.id).each do |patient|
      hash[patient.id] = "#{patient.given_name} #{patient.family_name}"
    end
    return hash
  end

  def patients_missed_medication
    latest_resolutions = Resolution.where(kind: "MissedMedication", patient: self.patients).select("MAX(resolved_at) as last_resolution, patient_id").group(:patient_id)
    new_list = []

    reports_per_patient = DailyReport.since_last_missing_resolution.where(patient: self.patients).group(:user_id).count()

    latest_resolutions.each do |resolution|
      days_since = (DateTime.now.to_date - resolution.last_resolution.to_date).to_i
      puts("#{resolution.patient_id} #{days_since}")
      if (!reports_per_patient[resolution.patient_id].nil? && days_since > reports_per_patient[resolution.patient_id]  )
        new_list.push(resolution.patient_id)
      end
    end

    puts(new_list)
    return(new_list)
  end

  def patients_where_photo_day
    to_send = []
    select = self.patients.active
    select.each do |patient|
      list = JSON.parse(patient.medication_schedule)
      puts("items #{list[patient.weeks_in_treatment]}")
      puts(DateTime.now.in_time_zone("America/Argentina/Buenos_Aires"))

    end

  end

end
