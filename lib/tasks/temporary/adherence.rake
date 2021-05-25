namespace :adherence do
    desc "Add "
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
  end
  