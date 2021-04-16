## Notes on pushing out an update to the production instance of the application

When rails is in production mode ie ```RAILS_ENV=production``` dockerized updates are a little more finicky than in development mode. When updating follow this process:

1. Pull in any configuration changes from github ```git pull ```
2. Pull in the latest image ```docker-compose pull web```
3. Restart effected services ```docker-compose up -d```
4. Run migrations ```docker-compose exec web bash => bundle exec rails db:migrate```
5. Restart services ```docker-compose restart web sidekiq```

Should be good to go 🙂

Its important to restart after migrations or models will not be able to find the new columns.  

