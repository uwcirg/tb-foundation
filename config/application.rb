require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Assemble
  class Application < Rails::Application
  # Initialize configuration defaults for originally generated Rails version.
  config.load_defaults 5.1
  config.api_only = true
  config.middleware.use ActionDispatch::Cookies

  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.fallbacks = [:en]

  #So that sidekiq worker classes are loaded
  config.autoload_paths += %W(#{config.root}/app/workers)

  # in config/application.rb
  #config.action_dispatch.default_headers = {
  #  'Access-Control-Allow-Origin' => '*',
  #  'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
  #}

  orgins_env = ENV['CORS_ORIGINS'] || ["localhost:5062"]

  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins orgins_env.split(',').map { |origin| origin.strip }
      resource '*', headers: :any, methods: [:get, :delete, :post, :options, :patch], credentials: true
    end
  end

  config.filter_parameters += [:password_digest,:push_url]

  

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
