# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "v2/swagger.yaml" => {
      openapi: "3.0.1",
      components: {
        schemas: {
          channel:{
            type: "object",
            properties:{
              id: { type: "integer"},
              title: { type: "string", example: "General Discussion"},
              subtitle: {type: "string", nullable: true },
              messagesCount: {type: "integer"},
              isPrivate: {type: "boolean"},
              updatedAt: {type: "string", format: "date-time"},
              userId: {type: "integer", nullable: true },
              lastMessageTime: {type: "string", format: "date-time"},
              userType: {type: "string", nullable: true },
              isSiteChannel: {type: "boolean"},
            }
          },
          update_patient:{
            type: "object",
            properties:{
              phoneNumber: {type: "string"},
              givenName: {type: "string"},
              familyName: {type: "string"},
              treatmentStart:{type: "string", format: "date-time"}
            }
          },
          patient: {
            type: "object",
            properties: {
              givenName: { type: "string" },
              familyName: { type: "string" },
              treatmentStart: { type: "string" },
            },
            required: %w[givenName familyName]
          },
          push_notification_status_update: {
            type: "object",
            properties:{
              deliveredSuccessfully: {type: "boolean", example: true},
              deliveredAt: {type: "string", format: "date-time"}, 
              clicked: {type: "boolean", example: true},
              clickedAt: {type: "string", format: "date-time"}
            }
          },
          push_subscription_update:{
            type: "object",
            properties:{
              pushAuth: {type: "string", example: "fCcSIGV5vYUJVIbzG-DvZA"},
              pushUrl: {type: "string", example: "https://www.example.com" }, 
              pushP256dh: {type: "string", example: "BJD99f2Z04fMPPJEpL8u6oAd3BHnTMxuKfsXT_wP" }, 
              pushClientPermission: {type: "string", example: "granted"}
            }
          }
        },
        securitySchemes: {
          cookie_auth: {
            type: :apiKey,
            name: "jwt",
            in: :cookie,
          },
        },
      },
      info: {
        title: "API V2",
        version: "v2",
      },
      paths: {},
      servers: [
        {
          url: ENV["URL_API"],
          variables: {
            defaultHost: {
              default: ENV["URL_API"],
            },
          },
        },
      ],
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
