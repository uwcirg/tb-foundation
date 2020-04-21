docker-compose restart db;
docker-compose exec web /bin/bash -c 'bundle exec rails db:reset';