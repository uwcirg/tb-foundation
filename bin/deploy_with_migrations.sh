#!/bin/sh -e

#docker-compose commands must be run in the same directory as docker-compose.yaml
cd "../"

echo "📦 Updating images..."
docker-compose pull web client;

echo "🚀 Deploying containers..."
docker-compose up -d;

echo "Running db migrations..."
docker-compose exec web bash -c "bundle exec rails db:migrate"

#Rails services need to be restarted for new database columns to be reflected in the application
echo "Restarting services..."
docker-compose restart web sidekiq;