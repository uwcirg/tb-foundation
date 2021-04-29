namespace :channels do
    desc "Add messaging channel per site for site level announcements - 4/16/21"
    task :initalize_site_channels => :environment do
      sites = Organization.all
      admin_id = Administrator.first.id

      puts "Going to create #{sites.count} site level channels"

      ActiveRecord::Base.transaction do
        sites.each do |site|
          site.create_organization_channel
        end
      end
  
      puts " All done now!"
    end

    desc "convert old public channels to new format"
    task :convert_existing_channels => :environment do
      public_channels = Channel.where(is_private: false)
      patient_channels = Channel.where(user: Patient.all)

      ActiveRecord::Base.transaction do
        public_channels.update_all(category: "StudyGroup")
        patient_channels.update_all(category: "Patient")
      end

    end


  end
  