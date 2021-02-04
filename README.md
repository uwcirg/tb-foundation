## TB-Foundation: A backend for [TB Mobile App](https://github.com/uwcirg/tb-mobile-app)

### Automated Tests
![RSpec Tests](https://github.com/uwcirg/tb-foundation/workflows/test/badge.svg)

This is the backend API for a project intended to improve tuberculosis treatment outcomes. It allows users to report their medication use and check in with providers throughout their treatment. 


## Run Rspec tests (example file provided)
docker-compose run --rm -e "RAILS_ENV=test" web rspec spec/requests/get_patients_spec.rb

## Helpful Commands

Launch Rails Console
```
docker-compose exec web bin/rails c
```

Add a photo day to the first test account (for debugging)
```
Patient.first.add_photo_day
```

