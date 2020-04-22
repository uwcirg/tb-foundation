class Practitioner < User
    has_many  :patients
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

    def get_photos
        #If you need more information from the DailyReport change this query to use DailyReport as the base, then join the other tables
        photos_needing_approval = PhotoReport.where(approved: nil).joins(:daily_report).joins(:user).where(users: {practitioner_id: self.id})
        list = []
        photos_needing_approval.each do |report|
                list.push({"url":report.get_url, "photo_id": report.id})
        end

        return list
    end

end