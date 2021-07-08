require "swagger_helper"

describe "Push Notification Routes" do
  before(:all) do
    create_first_organization
    @id = @patients[0].id
  end

  before do |example|
    unless example.metadata[:skip_login]
      cookie_for_user({ password: "password", phone_number: @patients[0].phone_number })
    end
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  path "/v2/vapid_public_key" do
    get "get vapid key" do
      tags "Notifications"
      produces "application/json"
      consumes "application/json"
      parameter name: :pushClientPermission, in: :path, type: :string
      response "200", "Successfully fetched vapid public key" do
        let!(:pushClientPermission) { "granted" }
        run_test!
      end

      response "401", "Not Authorized", skip_login: true do
        let!(:pushClientPermission) { "granted" }
        run_test!
      end
    end
  end

  path "/v2/user/{id}/push_subscription" do
    patch "Update user push subcription" do
      tags "Notifications"
      produces "application/json"
      consumes "application/json"
      parameter name: :push_subscription_update, in: :body, schema: { "$ref" => "#/components/schemas/push_subscription_update" }
      parameter name: :id, in: :path, type: :string

      response "200", "Successfully update push subscription details" do
        let!(:id) { @patients[0].id }
        let!(:push_subscription_update) {
          {
            pushAuth: "fCcSIGV5vYUJVIbzG-DvZA",
            pushUrl: "https://www.example.com",
            pushP256dh: "BJD99f2Z04fMPPJEpL8u6oAd3BHnTMxuKfsXT_wP",
            pushClientPermission: "granted"
          }
        }
        run_test!
      end

      response "401", "Not Authorized", skip_login: true do
        let!(:id) { @patients[0].id }
        let!(:push_subscription_update) {
          {
            pushAuth: "fCcSIGV5vYUJVIbzG-DvZA",
            pushUrl: "https://www.example.com",
            pushP256dh: "BJD99f2Z04fMPPJEpL8u6oAd3BHnTMxuKfsXT_wP",
            pushClientPermission: "granted"
          }
        }
        run_test!
      end
    end
  end

  path "/v2/push_notification_status/{id}" do
    patch "update push status" do
      tags "Notifications"
      produces "application/json"
      consumes "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :update_push_notification_status, in: :body, schema: { "$ref" => "#/components/schemas/push_notification_status_update" }

      response "201", "push notification status update successful" do
        let!(:id) { PushNotificationStatus.create!(user_id: @patients[0].id, notification_type: 0).id }
        let!(:update_push_notification_status) {
          {
            delivered_at: DateTime.now.iso8601,
            delivered: true,
          }
        }
        run_test!
      end

      response "401", "Unauthorized to access that users push notification statuses" do
        let!(:id) { PushNotificationStatus.create!(user_id: @patients[1].id, notification_type: 0).id }
        let!(:update_push_notification_status) {
          {
            delivered_at: DateTime.now.iso8601,
            delivered: true,
          }
        }
        run_test!
      end
    end
  end
end
