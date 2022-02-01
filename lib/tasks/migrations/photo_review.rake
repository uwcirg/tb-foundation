namespace :photo_review do
  desc "Seed coding categories"
  task :seed_categories => :environment do
    ActiveRecord::Base.transaction do
      if (Rails.env == "development")
        #Reset test data
        CodeApplication.destroy_all
        PhotoReview.destroy_all
        PhotoCodeGroup.destroy_all
        PhotoCode.destroy_all
        TestStripVersion.destroy_all
        PhotoReviewColor.destroy_all
      end

      group_one = PhotoCodeGroup.create!(group: "Photo Quality", group_code: 1)
      PhotoCode.create!(photo_code_group: group_one, sub_group_code: 1, title: "Far Away photo", description: "Photo taken from long distance")

      ["White", "Yellow", "Orange", "Pink", "Grey", "Light Blue", "Blue", "Dark Blue", "Light Purple", "Purple", "Dark Purple", "Purple Blue", "Teal"].each {
        |color|
        PhotoReviewColor.create!(name: color)
      }

      TestStripVersion.create!(version: 1, description: "Original One Line", id_range_description: "First 100 cartridges", shipment_date: (Time.now - 20.months).to_date)
    end

    puts " All done now!"
  end
end
