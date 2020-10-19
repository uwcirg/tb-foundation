# lib/tasks/temporary/users.rake
namespace :messaging do
  desc "Create channels for all practitioners to chat with expert"
  task :create_expert_channels => :environment do
    coordinators = Practitioner.all
    puts "Going to create expert channels for #{coordinators.count} coordinators"
    ActiveRecord::Base.transaction do
      coordinators.each do |coordinator|
        coordinator.create_private_message_channel
      end
    end
    puts " All done now!"
  end
end
