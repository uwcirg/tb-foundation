require "rails_helper"

RSpec.describe Organization, type: :model do
  before(:all) do
    create_first_organization
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe "Messaging Channels Creation" do
    it("creates a site level channel after commit") do
      expect(Channel.where(organization_id: @organization.id).count).to equal(1)
    end
    
    it("allows patients access to that channel") do
      expect(@patients[0].available_channels).to include(Channel.find_by(organization_id: @organization.id))
    end

    it("allows practitioners access to that channel") do
      expect(@practitioner.available_channels).to include(Channel.find_by(organization_id: @organization.id))
    end

    it("Creating a new site will create the channel and unread messages") do
      create_second_organization
      channel_id = Channel.find_by(organization_id: @organization_two.id).id
      expect(Organization.all.count).to be(2)
      expect(Channel.where(organization_id: @organization_two.id).count).to be(1)
      expect(@patients_two[0].available_channels).to include(Channel.find_by(organization_id: @organization_two.id))
      
      #One patient and one asistant
      expect(MessagingNotification.where(channel_id: channel_id).count).to be(2)
     
    end

  end
end
