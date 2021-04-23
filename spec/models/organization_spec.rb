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

  end
end
