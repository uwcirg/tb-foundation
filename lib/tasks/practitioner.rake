# lib/tasks/temporary/users.rake
namespace :practitioner do
  desc "Fix Unread Messages"
  task :fix_unread_messages => :environment do
    users = Practitioner.all
    puts "Going to update #{users.count} practitioners"
    ActiveRecord::Base.transaction do
      users.each do |user|
        Channel.where(user_id: user.patients.pluck(:id)).where("id NOT IN (?)", user.messaging_notifications.pluck(:channel_id)).each do |channel|
            user.messaging_notifications.create!(channel_id: channel.id)
        end
      end
      
    end

    puts " All done now!"
  end

  desc "Initalize Expert Channels"
  task :create_expert_channels => :environment do
    users = Practitioner.all
    puts "Going to create #{users.count} channels"
    ActiveRecord::Base.transaction do
      users.each do |user|
        user.channels.create!(title: "tb-expert-chat", is_private: true)
      end
      
    end

    puts " All done now!"
  end


end
