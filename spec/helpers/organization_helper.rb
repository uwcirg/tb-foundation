module OrganizationHelper
    def create_second_organization
        @organization_two = FactoryBot.create(:organization)
        @practitioner_two = FactoryBot.create(:practitioner, organization: @organization_two)
        @patients_two = FactoryBot.create_list(:random_patients, 1, organization: @organization_two)
      end
      
      def create_first_organization
        @organization = FactoryBot.create(:organization)
        @practitioner = FactoryBot.create(:practitioner, organization: @organization)
        @patients = FactoryBot.create_list(:random_patients, 3, organization: @organization)
      end
end