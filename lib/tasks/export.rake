require "csv"

namespace :export do
  desc "Create channels for all practitioners to chat with expert"
  task :photo_report_csv => :environment do

    #Available attributes 
    # "id", "daily_report_id", "photo_url", "approved", "approval_timestamp", 
    # "user_id", "practitioner_id", "date", "photo_was_skipped", 
    # "why_photo_was_skipped", "created_at", "updated_at", "back_submission"

    #We want to rename a few columns for clarity
    column_names = %w{date created_at photo_report_id user_id photo_file_name marked_conclusive reviewed_by_practitioner_id reviewed_timestamp}

    CSV.generate(headers: true) do |csv|

      file = "#{Rails.root}/tmp/photo_reports.csv"
      relevant_reports = PhotoReport.where(patient: Patient.non_test).where('daily_report_id is NOT NULL AND photo_url is not null').includes(:daily_report)

      CSV.open(file, 'w', write_headers: true, headers: column_names) do |writer|
        relevant_reports.each do |report|
            writer << [report.date, report.daily_report ? report.daily_report.created_at : "", report.id, report.user_id, 
              report.photo_url, report.approved, report.practitioner_id, report.approval_timestamp]
          end
      end
    end
  end
end
