class DailyNotification < ApplicationRecord
    belongs_to :user

    def update_time(new_time)
        self.update!(time: new_time)
    end

    def get_user
        return Patient.find(self.user_id)
    end

    def as_json(*args)
        {
            time: self.time,
            isoTime: self.formatted_time
        }
    end

    def formatted_time
        return self.time.strftime("%T%:z")
    end

end
  