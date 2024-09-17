# Use the official NGINX image from Docker Hub
FROM nginx:latest

# Copy the ActiveWebsite directory into the container
COPY ActiveWebsite /usr/share/nginx/html

# Copy the custom NGINX config file to the container's /etc/nginx/sites-available/default location
COPY ./nginx-conf/current-nginx.conf /etc/nginx/sites-available/default

# Copy the SSL certificate and private key into the container
COPY ssl/selfsigned.crt /etc/ssl/certs/selfsigned.crt
COPY ssl/selfsigned.key /etc/ssl/private/selfsigned.key

# Expose port 443 for HTTPS traffic
EXPOSE 443

# Set ownership and permissions for the website files
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && chmod -R 750 /usr/share/nginx/html

# Ensure the /etc/nginx/sites-enabled directory exists
RUN mkdir -p /etc/nginx/sites-enabled

# Create a symlink to enable the config
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
