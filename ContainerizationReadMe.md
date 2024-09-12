# Containerization
## Dockerizing Website (Pre-Login/Updated Files)

### Objectives
- I'm containerizing our website with Docker to eventually make the active website easier to host.
- I'm attempting to use a Docker file to make a nginx image to host a website on my local host.

### Run Project Locally
#### Ensure all necessary files are downloaded.
- docker -v (Check to make sure Docker is installed on your local system.)
> Traverse into the folder you intend to store your Docker/Website in.

#### Creating a Dockerfile
- touch Dockerfile (Creates a Dockerfile)
- vim Dockerfile (Edits Dockerfile)
> Current Dockerfile as of Sept 12th 2024
```  
FROM nginx:latest (copies nginx's current image from docker)

# Copy the ActiveWebsite directory into the container
COPY ActiveWebsite /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Changes owner and permisions of the now moved ActiveWebsite directory
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R 750 /usr/share/nginx/html

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
```

#### After creating a Dockerfile, you will want to go into your commandline and run the command:
> "docker build -t {ImageName} ."
* *the -t allows you to name the image (it must be all lowercase letters) the . after imageName is to signify that you are building this from the Dockerfile in your current directory*
>
#### After building the image in the previous step, you will want to go back into your commandline and run the command:
> "docker run -d -p 8080:80 dockerfile"
* *the -d allows you to detatch from hosting your cose allowing you to still access the terminal as the container runs*
* *the -p allows you to publish what you've done to the host, in this case pushes the index.html to the wbpage* 

#### Currently this is being run under Localhost for the time being.

#### what does it do and when
##### *it runs a preset action you write and it runs it when you push the action to a branch of your choosing (mostly main)*

#### what variables in workflow are custom to your project
##### *I changed the call for my DockerHub Username & Password*
##### *I also changed the repo name within the active workflow*

