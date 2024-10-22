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

