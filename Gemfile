ruby "2.5.3"
source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rack-cors"
gem "bcrypt", "~> 3.1"
gem "pg", "~> 0.18"
gem "puma", "~> 3.12"
gem "rails", "~> 6.0"
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'jwt'
gem 'rubyzip'
gem 'webpush'
gem 'aws-sdk', '~> 3'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'active_model_serializers'

group :development, :test do
  # Call `byebug` to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "pry"
  gem 'rspec-rails', '~> 4.0.1'
end

