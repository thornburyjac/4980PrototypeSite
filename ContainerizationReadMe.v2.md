# Containerization
## Dockerizing Website (1FA / HTTPS Setup)

### Objectives
- I'm expanding the containerization to run on an HTTPS instead of HTTP
- I'm using the updated site files that now prompt a login before achieving the second page landing
- I created a script in which I can run my dockerfiles in one button push instead of several.

### Updated Files for HTTPS and 1FA
#### Updated Dockerfile
> Current Dockerfile as of Oct 8th 2024
```
# Use the official NGINX image from Docker Hub
FROM nginx:latest

# Remove the default NGINX config file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom NGINX config file directly to /etc/nginx/conf.d/
COPY nginx-conf/current-nginx.conf /etc/nginx/conf.d/default.conf

# Copy the SSL certificate and private key into the container
COPY ssl/selfsigned.crt /etc/ssl/certs/selfsigned.crt
COPY ssl/selfsigned.key /etc/ssl/private/selfsigned.key

# Expose port 443 for HTTPS traffic
EXPOSE 443

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
```


#### Updated nginx-config
> Current nginx-config as of Oct 8th 2024
```  
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name localhost;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;  # Ensure the path is correct
    ssl_certificate_key /etc/ssl/private/selfsigned.key;  # Ensure the path is correct

    # Add SSL protocols and ciphers for secure communication
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        root /usr/share/nginx/html;  # Adjust this if necessary
        try_files $uri $uri/ =404;
    }

    # Authenticated route
    location /authreq {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;  # Make sure this file exists
        root /usr/share/nginx/html;  # Use the correct root directory
        index obiwan.html;  # Make sure obiwan.html exists in this directory
    }
}
```
### Creating a Script to auto-build and auto-run my current Container files
#### New Script File
> Current Script file as of Oct 8th 2024
```
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
```
