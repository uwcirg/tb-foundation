namespace :photo_review do
    desc "Seed coding categories"
    task :seed_categories => :environment do

      ActiveRecord::Base.transaction do
        group_one = PhotoCodeGroup.create!(group: "Photo Quality", group_code: 1)
        PhotoCode.create!(photo_code_group: group_one, sub_group_code: 1, title: "Far Away photo", description: "Photo taken from long distance")

        PhotoReviewColor.create!(name: "Dark Blue")

        TestStripVersion.create!(version: 1, description: "Original One Line", id_range_description: "First 100 cartridges", shipment_date: (Time.now - 20.months).to_date )
      end
  
      puts " All done now!"
    end
  end
  