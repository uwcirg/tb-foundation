require "swagger_helper"

describe "Messaging Channels" do
  before(:all) do
    create_first_organization
  end

  before do |example|
    unless example.metadata[:skip_login]
      cookie_for_user({ password: "password", email: @practitioner.email })
    end
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  path "/v2/channels" do
    get "channels" do
      tags "Channel"
      produces "application/json"
      consumes "application/json"

      response "200", "success" do

        schema type: :array, 
        items:  { "$ref" => "#/components/schemas/channel"}


        # examples 'application/json' => {
        #     id: 1,
        #     title: "General Discussion",
        #     subtitle: 'Hello world!',
        #     isPrivate: false,
        #     isSiteChannel: false,
        #     userType: "Default",
        #     messagesCount: 4,
        #     lastMessageTime: "2021-04-23T18:58:13.191Z",
        #     createdAt: "2021-04-19T21:24:33.922Z",
        #     updatedAt: "2021-04-19T21:24:33.922Z",

        #   }

        run_test!
      end
    end
  end
end
