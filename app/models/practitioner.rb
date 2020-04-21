class Practitioner < User
    has_many  :patients
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

    def get_photos
        pr = DailyReport.where.not(photo_report: nil)
        hash = {}
        num = 0
        pr.each do |report|
            hash["#{report.id}"] = report
            num+=1
        end
        hash["num"]= {"num": num}
        return hash
    end

end