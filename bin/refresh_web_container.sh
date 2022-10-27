#!/bin/sh -e
git pull;
docker build -t uwcirg/tb-foundation:develop .;
docker-compose up -d web sidekiq;