namespace :override do
    task :default do
      puts "Overriden Default Rake Task. This prevents tests from destroying the database. Use rspec to run tests"
    end
  end

  task(:default).clear.enhance ["override:default"]