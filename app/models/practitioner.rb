class Practitioner < User
    has_many  :patients
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

    def get_photos
        #pr = DailyReport.joins(:user).joins(:photo_report)
        pr = PhotoReport.where(approved: nil).joins(:user).where(users: {practitioner_id: self.id})
        puts(pr)
        list = []
        num = 0
        puts("Query Length")
        puts(pr.length)
        pr.each do |report|
                list.push({"url":report.get_url, "photo_id": report.id,"p_id": report.assigned_practitioner})
        end
        return list
    end

end