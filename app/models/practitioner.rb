class Practitioner < User
    has_many  :patients
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

    def get_photos
        pr = DailyReport.all.joins(:photo_report)
        list = []
        num = 0
        puts("Query Length")
        puts(pr.length)
        pr.each do |report|
            if(!report.photo_report.nil?)
                list.push({"url":report.photo_report.get_url, "photo_id": report.photo_report.id})
            end
        end
        return list
    end

end