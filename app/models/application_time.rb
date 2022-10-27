class ApplicationTime
    
    def self.time_zone
        ENV["DEPLOY_TIME_ZONE"] || "America/Argentina/Buenos_Aires"
    end

    def self.todays_date
        Time.now.in_time_zone(time_zone).to_date
    end

end