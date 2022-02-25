require "csv"

namespace :test_strip_versions do
  desc "Add new strip version list"
  task :add_v2_test_strip_versions => :environment do

    backup_json = PhotoReview.all.joins(:test_strip_version).select("photo_reviews.id, test_strip_versions.version as old_version_number").to_json
    File.write("#{Rails.root}/tmp/photo-review-version-id-backup.json",backup_json)

    file = File.read("#{Rails.root}/app/assets/v2-test-strip-versions.json")
    new_versions_list = JSON.parse(file)
    ActiveRecord::Base.transaction do
      PhotoReview.update_all(test_strip_version_id: nil)
      TestStripVersion.destroy_all
      new_versions_list.each { |v|
              TestStripVersion.create!(version: v["version"], description: v["description"], id_range_description: v["range"], shipment_date: v["shipment_date"])
      }
    end

  end
end
