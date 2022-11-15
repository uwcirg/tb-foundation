class ApplicationTime
  def self.time_zone
    Rails.cache.fetch("time_zone", expires_in: 1.days) do
      env_value = ENV["DEPLOY_TIME_ZONE"]
      if env_value.presence && TZInfo::Timezone.all_country_zone_identifiers.include?(env_value)
        return env_value
      end
      "America/Argentina/Buenos_Aires"
    end
  end

  def self.todays_date
    Time.now.in_time_zone(time_zone).to_date
  end
end