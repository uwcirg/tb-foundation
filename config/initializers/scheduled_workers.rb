require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|

  is_indonesia = ENV['INDONESIA_PILOT_FLAG'] == 'true'
  file_path_prefix = is_indonesia ? 'id' : 'ar'

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path("../../#{file_path_prefix}-schedule.yml", __FILE__))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end