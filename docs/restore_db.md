Check staging_transfer.sh for a similar script

Here I use "production" as the name for the database, this could vary based on deployment environment (ie. it could be called development or something else). I also use the postgres username "webuser" which is just what we are using from the default docker-compose setup on this project.

```
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
```