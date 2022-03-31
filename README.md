## TB-Foundation: A backend for [TB Mobile App](https://github.com/uwcirg/tb-mobile-app)

### Automated Tests
![RSpec Tests](https://github.com/uwcirg/tb-foundation/workflows/test/badge.svg)

This is the backend API for a project intended to improve tuberculosis treatment outcomes. It allows users to report their medication use and check in with providers throughout their treatment. 

## Getting started with development ( work in progress )


1. **Create .env file**
This will provide the dockerized services with the environment variables needed to get started. Some sensible defaults are provided in .sample.env

2. **Edit /etc/hosts** If using a local development environment modify /etc/hosts to include a redirect for bucket to localhost. This is required to file urls consistant internally and externally on docker. <br />```127.0.0.1 bucket```
	
3. **Spin up dockerized services**
<br />```docker-compose up -d```

4. **Setup and seed database for rails application**
<br />```docker-compose exec web bash -c 'bundle exec rake db:setup ```


## Run Rspec tests (example file provided)
docker-compose run --rm -e "RAILS_ENV=test" web rspec spec/requests/get_patients_spec.rb

- To skip to a specific test you can include the line number at the end (ie ```:104```)
- Can also run a whole "it" block if you specify that line

When working in vscode remote container mode I added an alias for easier testing ```rspec_test```

## Helpful Commands

Launch Rails Console
```
docker-compose exec web bin/rails c
```

Add a photo day to the first test account (for debugging)
```
Patient.first.add_photo_day
```

## Adding a new Ruby Gem
- Add gem to Gemfile
- run docker build -t uwcirg/tb-foundation .
- Redeploy

## Tests + API Documentation with rswag

- An alias has been created in the docker build ```create_docs``` that will generate the Swagger Documentation 
    - ```RAILS_ENV=test bundle exec rake rswag:specs:swaggerize PATTERN="spec/integration/\*\*/\*_spec.rb"```
- These docs can be accessed from https://base-url.com/api-docs
    - They will only be available in development environment
- Generating the docs does not run the tests, you can still run with the normal command above
- This is a good time saver, you can test the validity of API responses while also getting documentation out of it

## Issues with tests
Sometimes when adding gems or needing to upgrade versions, things can break with the installation of gems. If you get a message like this 
```Could not find rake-13.0.3 in any of the sources Run `bundle install` to install missing gems.``` just run ```docker-compose build web```
