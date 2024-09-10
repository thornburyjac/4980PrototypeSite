FROM nginx:latest

# Copy the ActiveWebsite directory into the container
COPY ActiveWebsite /usr/share/nginx/html

# Expose port 80
EXPOSE 80

#chmod & chown
RUN chown -R nginx:nginx /usr/share/nginx/html

RUN chmod -R 750 /usr/share/nginx/html

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
