namespace :deduplicate_daily_reports do
  desc "Delete duplicated daily reports"
  task :fix => :environment do
    ActiveRecord::Base.transaction do
      duplicates = DailyReport.select("user_id", "date").group("user_id", "date").having("count(user_id) > 1")
      daily_reports_ids = []
      duplicates.pluck("user_id", "date").each { |p| daily_reports_ids.push(DailyReport.where(user_id: p[0], date: p[1]).pluck(:id)) }
      to_keep = DailyReport.where(id: daily_reports_ids).group("user_id", "date").minimum("id").values
      to_delete = DailyReport.where(id: daily_reports_ids).where.not(id: to_keep)
      puts("Deleting #{to_delete.count} duplicated daily reports")
      to_delete.destroy_all
    end
  end
end
