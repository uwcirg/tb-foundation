namespace :photo_review do
  desc "Seed coding categories"
  task :seed_categories => :environment do

    #Read in JSON of test strip versions
    file = File.read("#{Rails.root}/app/assets/test-strip-versions.json")
    versions_list = JSON.parse(file)

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

      ["Image Quality", "Test Quality", "User Actions"]

      group_one = PhotoCodeGroup.create!(group: "Photo Quality", group_code: 1)
      PhotoCode.create!(photo_code_group: group_one, sub_group_code: 1, title: "Far Away photo", description: "Photo taken from long distance")

      ["White", "Yellow", "Orange", "Pink", "Grey", "Light Blue", "Blue", "Dark Blue", "Light Purple", "Purple", "Dark Purple", "Purple Blue", "Teal"].each {
        |color|
        PhotoReviewColor.create!(name: color)
      }

      versions_list.reverse.each {|v|
        TestStripVersion.create!(version: TestStripVersion.count + 1, description: v["description"], id_range_description: v["range"], shipment_date: v["shipment"])
      }

    end

    puts "All done now!"
  end
end
