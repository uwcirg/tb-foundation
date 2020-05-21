class Practitioner < User
    has_many  :patients
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

    def get_photos
        #If you need more information from the DailyReport change this query to use DailyReport as the base, then join the other tables
        photos_needing_approval = PhotoReport.where(approved: nil).joins(:daily_report).joins(:patient).where(users: {practitioner_id: self.id})
        return(process_photos(photos_needing_approval))
    end

    def get_historical_photos
        historical_photos = PhotoReport.where.not(approved: nil).joins(:daily_report).joins(:user).where(users: {practitioner_id: self.id})
        return( process_photos(historical_photos))
    end

    def process_photos(photos)

        list = []
        photos.each do |report|
                list.push({"url":report.get_url, "photo_id": report.id, "approved": report.approved})
        end

        return list

    end

    def patient_names
        hash = {}
        Patient.where(practitioner_id: self.id).each do |patient|
            hash[patient.id] = "#{patient.given_name} #{patient.family_name}"
        end
        return hash
    end

end