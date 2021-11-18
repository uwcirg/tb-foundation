require "csv"

namespace :export do
  desc "Create channels for all practitioners to chat with expert"
  task :photo_report_csv => :environment do
    attributes = %w{id photo_url approved approval_timestamp}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      file = "#{Rails.root}/tmp/photo_reports.csv"

      CSV.open(file, 'w', write_headers: true, headers: attributes) do |writer|
        PhotoReport.last(10).each do |report|
            writer << attributes.map { |attr| report.send(attr) }
          end
      end

      # PhotoReport.last(10).each do |report|
      #   csv << attributes.map { |attr| report.send(attr) }
      # end
      
    end
  end
end
