class Practitioner < User
    has_many :patients
    has_many :resolutions
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

    def get_photos
        #If you need more information from the DailyReport change this query to use DailyReport as the base, then join the other tables
        photos_needing_approval = PhotoReport.where(approved: nil).joins(:daily_report).joins(:patient).where(users: {practitioner_id: self.id})
        return(photos_needing_approval)
    end

    def get_historical_photos
        historical_photos = PhotoReport.where.not(approved: nil).joins(:daily_report).joins(:patient).where(users: {practitioner_id: self.id})
        return( process_photos(historical_photos))
    end

    def process_photos(photos)

        list = []
        photos.each do |report|
                list.push({"url":report.get_url, "photo_id": report.id, "approved": report.approved})
        end

        return list
    end

    def missed_since_last_resolution

        #Daily reports where time > than last resolution, where patients are in the coordinators list of patients
        #Where reports are less than number of days since last resolution
        start = DateTime.now - 1.week
        stop = DateTime.now - 1.day
        list = (start..stop).to_a

        return self.resolutions.find_by(kind: "MissedMedication").created_at
  
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

end