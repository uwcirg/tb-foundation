#!/bin/sh -e
bin_path="$(cd "$(dirname "$0")" && pwd)"
repo_path="${bin_path}/.."

#Backup DB to Kyles home folder
echo "🚧 Making a database backup..."
mkdir -p "/home/kjgood1/deploy-backups"
sh ./backup.sh -b "/home/kjgood1/deploy-backups/"

#docker-compose commands must be run in the same directory as docker-compose.yaml
cd "${repo_path}"

echo "📦 Updating images..."
docker-compose pull web client;

echo "🚀 Deploying containers..."
docker-compose up -d;

echo "Running db migrations..."
docker-compose exec web bash -c "bundle exec rails db:migrate"

#Rails services need to be restarted for new database columns to be reflected in the application
echo "Restarting services..."
docker-compose stop web sidekiq;
docker-compose rm web sidekiq;
docker-compose up -d;