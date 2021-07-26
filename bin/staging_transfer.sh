#!/bin/sh -e
cd "/srv/www/tb-api.cirg.washington.edu/tb-foundation/bin"
sh backup.sh || { echo "Backup of prod db failed"; exit 1; }

restore_file_name="$(ls -t /tmp | grep "tb-v2.sql" | head -n1)"

if [ -z "$restore_file_name" ]; then
     >&2 echo "Error: psql dump file not found"
     exit 1
fi

cd "/srv/www/tb-api-staging.cirg.washington.edu/tb-foundation" || { echo "Staging dir not found"; exit 1; } 

if [ "$PWD" != "/srv/www/tb-api-staging.cirg.washington.edu/tb-foundation" ]; then
     >&2 echo "Error: not currently in staging folder. Stoping to prevent prod db damage"
     exit 1
fi

echo "Stoping Services..."
docker-compose stop web sidekiq

echo "Dropping current db..."
docker-compose exec db dropdb --username webuser production

echo "Creating empty db..."
docker-compose exec db createdb --username webuser production

echo "Loading SQL dumpfile: ${restore_file_name}..."
docker-compose exec -T db psql --dbname production --username webuser < "/tmp/$restore_file_name"

echo "Restarting services"
docker-compose up -d
