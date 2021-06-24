1. Create .env file with required parameters
2. git clone https://github.com/uwcirg/tb-foundation.git
3. git checkout <branch you want>
4. docker-compose up -d
5. Initalize database:

If Initalizing from a database backup: (ENVIRONMENT_TYPE is development or production depending on deployment )
docker-compose exec db createdb --username webuser ENVIRONMENT_TYPE
docker-compose exec -T db psql --dbname ENVIRONMENT_TYPE --username webuser < /path/to/pg_dump.sql

Otherwise:
Follow rails way of intializing db. 
rake db:schema:load

Important Notes:

If you get this error on startup: ```/usr/local/lib/ruby/2.5.0/uri/generic.rb:208:in `initialize': the scheme postgres does not accept registry part: webuser:PASSWORD (or bad hostname?) (URI::InvalidURIError)```
Fix the postgres password. It cannot have special characters in it, just stick to letters / numbers 

Redis port is the default one, dont worry, since its not exposed the ports wont overlap since they are localized to the docker network
