#!/bin/bash

# Build the Docker image with the name 'my-updated-nginx'
docker build -t my-updated-nginx .

# Run the container with the name 'site-container'
sudo docker run -d \
  --name site-container \
  -p 8080:443 \
  -v $PWD/ActiveWebsite:/usr/share/nginx/html \
  -v $PWD/nginx-conf/current-nginx.conf:/etc/nginx/sites-available/default \
  -v $PWD/ssl/selfsigned.crt:/etc/ssl/certs/selfsigned.crt \
  -v $PWD/ssl/selfsigned.key:/etc/ssl/private/selfsigned.key \
  my-updated-nginx

