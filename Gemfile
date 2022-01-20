ruby "2.5.3"
source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rack-cors"
gem "bcrypt", "~> 3.1"
gem "pg", "~> 0.18"
gem "puma", "~> 4.3"
gem "rails", "~> 6.0.4.4"
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "jwt"
gem "rubyzip", "~> 2.3.0"
gem "webpush"
gem "aws-sdk-s3", "~> 1"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "active_model_serializers"
gem "rest-client"
gem "pundit"
gem "rswag"

group :development, :test do
  # Call `byebug` to stop execution and get a debugger console
  gem "rufo"
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "pry"
  gem "rspec-rails", "~> 4.0.1"
  gem "faker"
  gem "factory_bot_rails"
  gem "database_cleaner-active_record"
end
