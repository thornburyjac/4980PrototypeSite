# Containerization
## Dockerizing Website (MFA / Certification Setup)

### Objectives
- I'm expanding the containerization to connect via a Certification and Login past the Hub HTTPS Page
- I'm using the updated site files that now send to port 444 after pressing one button
- I created a script in which I can stop my dockerfiles in one button push instead of several.
- I editted the HTML to update links based on the current host IP.

### Updated Files for Certification & MFA
#### Updated Dockerfile
> Current Dockerfile as of Oct 22nd 2024
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
COPY ssl/testuser.crt /etc/ssl/certs/testuser.crt
COPY ssl/password /etc/nginx/.htpasswd

# Expose port 80 & 443 & 444 for HTTP & HTTPS traffic
EXPOSE 80
EXPOSE 443
EXPOSE 444

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

```


#### Updated nginx-config
> Current nginx-config as of Oct 22nd 2024
```  
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Redirect all HTTP traffic to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name localhost;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;

    # Other SSL configuration directives can go here

        location / {
                root /usr/share/nginx/html;
                try_files $uri $uri/ =404;
        }
}

server {
    listen 444 ssl;
    listen [::]:444 ssl;
    server_name localhost;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;  # Ensure the path is correct
    ssl_certificate_key /etc/ssl/private/selfsigned.key;  # Ensure the path is correct
    ssl_client_certificate /etc/ssl/certs/testuser.crt; # Ensure the path is correct

    # Add SSL protocols and ciphers for secure communication
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_verify_client on;

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
### Updated a Script to auto-build and auto-run my current Container files
#### Updated Script File
> Current Script file as of Oct 22nd 2024
```
#!/bin/bash

# Build the Docker image with the name 'my-updated-nginx'
docker build -t my-updated-nginx .

# Run the container with the name 'site-container'
docker run -d \
  --name site-container \
  -p 80:80\
  -p 443:443\
  -p 444:444 \
  -v $PWD/ActiveWebsite:/usr/share/nginx/html \
  -v $PWD/nginx-conf/current-nginx.conf:/etc/nginx/sites-available/default \
  -v $PWD/ssl/selfsigned.crt:/etc/ssl/certs/selfsigned.crt \
  -v $PWD/ssl/testuser.crt:/etc/ssl/certs/testuser.crt\
  -v $PWD/ssl/selfsigned.key:/etc/ssl/private/selfsigned.key \
  my-updated-nginx
```
### Created a Script to auto-rm and auto-rmi my current Container files
#### New Script File
```
#!/bin/bash
docker rm site-container -f
docker rmi my-updated-nginx -f
```
### Created a HTML Script to capture current IP and use it to send users to 444 port of that IP
#### New HTML Script snip
```
<script>
        function createLink() {
            // Get the IP address or hostname and port from the input fields
            // Get the current hostname of the page
            const hostname = window.location.hostname;
            const port = '444'; 

            // Construct the URL
            const url = `https://${hostname}:${port}`;
	    
	    //Send to port 444
            window.location.href = url;
        }
    </script>
...
<a id="connection-link" href:"#" onclick="createLink()" class="link">Click here if you are Obi-Wan Kenobi.</a>

```
