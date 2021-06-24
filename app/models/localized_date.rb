class LocalizedDate

    def initialize(time_zone)
        @time_zone = time_zone
    end

    def self.now_in_ar
        Time.now.in_time_zone("America/Argentina/Buenos_Aires")
    end

    def self.today_in_ar
        Time.now.in_time_zone("America/Argentina/Buenos_Aires").to_date
    end

    def today
        Time.now.in_time_zone(@time_zone).to_date
    end

end