namespace :channels do
    desc "Add messaging channel per site for site level announcements - 4/16/21"
    task :initalize_site_channels => :environment do
      sites = Organization.all
      admin_id = Administrator.first.id

      puts "Going to create #{sites.count} site level channels"

      ActiveRecord::Base.transaction do
        sites.each do |site|
          Channel.create!(user_id: admin_id, is_private: true, title: site.title, category: "Site", organization_id: site.id);
        end
      end
  
      puts " All done now!"
    end
  end
  