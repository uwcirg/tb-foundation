require "rails_helper"

RSpec.describe Organization, type: :model do
  before(:all) do
    create_first_organization
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe "After Create Hooks" do
    it("creates a site level channel after commit") do
      expect(Channel.where(organization_id: @organization.id).count).to equal(1)
    end
  end
end
