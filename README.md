# CONTENTS
WebsiteFiles contains the html, css, and images that go with the website

YAML contains the yaml file you will use to deploy the instance

This README walks you through the process to deploy the instance and configure it to serve the prototype site.

# Part 1: Using AWS CloudFormation to deploy the instance
- Log in to AWS using https://awsacademy.instructure.com/
- In the search bar in the top right type "Cloudformation".

![searchcloudformation](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/f6d9da75-7947-4dd2-81ea-7a08080374f5)

- Select "Create Stack with new resources".

![createstack](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/8054e1cf-9d99-4b32-ba36-c6cfd9e4b630)

- Select "Template is ready" and "Upload a template file".

![chooseyaml](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/8c98c69c-03c2-41e7-8e31-9ea1eadf92c4)

- Select "choose file" and navigate to the yaml file provided then hit next.
- Give the stack a name, and select a key pair (KNOW WHAT KEY YOU ARE SELECTING, YOU WILL NEED IT TO ACCESS THE INSTANCE).

![stackname](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/c9fbc3b2-9001-4369-9cdd-10656019300d)

- Next through all the following screens, default settings are fine for testing.
- You should get a create complete message, if you did not then you will need to reassess the yaml and settings.

![createcomplete](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/f7e2e386-8b30-4a8c-a6b3-15b97ebd093a)

- The instance should be availabe to ssh into for configuration.

# Part 2: Configuring the instance to serve the website via HTTP
- You should be able to navigate to EC2 in AWS using the search bar, and see the instance. You can select the instance to view its IP address.

![ec2instances](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/db6bb591-38d7-4892-bb9a-aeffaa95e95a)

- Use ssh to access the instance for configuration. This command will allow you to remotely configure the instance `ssh -i /home/jacob/.ssh/labsuser.pem ubuntu@44.205.210.252`.
- Breakind down the above command, ssh is the protocol you are using for remote access. The -i option allows you to specify the "identity file" which is the corresponding private key to the public key on the instance you selected in Part 1. Ubuntu@IP is the username you are logging in as on the host system which is the IP you specify.
- Once in the instance, verify the hostname changed and verify nginx is installed.

![sshintoinstance](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/40811991-4b41-4c4c-80c0-ed1c3f373278)

- You can use sftp on your local machine to dump the site files onto the instance using command `sftp -i /home/jacob/.ssh/labsuser.pem ubuntu@44.205.210.252`. Pretty much same breakdown as the ssh command.
- Once in an sftp prompt, use the put <filename> command to "put" the file on the remote machine. Use pwd and lpwd to view remote and local working directory.

![sftp](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/98e0c320-426a-4082-b3dc-6b9938924ede)

- Once the site files are on the instance, you need to put them in the directory that nginx serves html, which is /var/www/html. You can do this using a command on the instance.
- You should be able to do this with a command that looks like `sudo mv /home/ubuntu/4980_testsite /var/www/html/`
- You need to configure nginx to serve your site files instead of the default nginx files. Navigate to /etc/nginx/sites-available and edit the default file which is the config file.
- In the default config file there should be a line that looks like root /var/www/html;, change it to root /var/www/html/4980_testsite;
- Change permissions on the website files using commands `sudo chown -R www-data 4980_testsite` and `sudo chmod -R 750 4980_testsite` while in the /var/www/html directory.
- Permissions need changing because the www-data is the user the nginx service uses, so that user needs to have the access to the files. You can still use sudo to make changes/view the files after the permissions have been changed. Or change the group and group permissions and add yourself to the group.
- Restart and verify nginx is running after all thesee changes using "sudo systemctl restart nginx" and "sudo systemctl status nginx".
- Test site functionality by putting the IP address of the instance in the address bar of a web browser.

# Part 3: Configuring the instance to serve the website via HTTPS

Based on https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04

- ssh into the system if your not already.
- Setup the self signed cert using this command `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt`
- So that command creates all the necessary files and puts them in the default folders nginx sets up for ssl stuff.
- Now we need to setup the nginx config file, /etc/nginx/sites-available/default.
- Open that file, remove everything and add...

```text
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Redirect all HTTP traffic to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name _;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    # Other SSL configuration directives can go here

    location / {
        root /var/www/html/4980_testsite;
        index index.html;
    }
}
```
Breaking this file down, we have 2 server blocks, and a location block. The first server block is for telling nginx to listen on port 80 and to redirect http requests to port 80 to port 443 which is for https. The second server block is telling nginx to listen on port 443, telling nginx for requests that dont specify a host to just use default, and telling nginx where the cert file and the key for the cert file is. The third block within the second block is the location block. This is for telling nginx where to look for the html files, and what is the landing page which in almost all websites is called index.html.

- Once the cert and key are where they need to be, and the configuration file is created, now you can test it.
- Restart the nginx service using `sudo systemctl restart nginx.service`
- Confirm it is up and working using `sudo systemctl status nginx.service`
- You can test if the nginx config file is valid (not "working" but valid in terms of syntax) using `sudo nginx -t`
- Once all this is done, either clear your browser cache or use a private window because old versions of the site might be cached.
- Once again, drop the IP address into the browser address bar. You should not have to specify https because it should be redirecting all requests to use https.
- Depending on the browser, you will need to click "advanced" and "continue to site" because of the self signed certificate error, I will elaborate on this later.
- It should look like the below screenshot if its working...

![httpsworking](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/7dc52b3e-8e8f-4e75-adb3-9cd2757d3502)

- The below screenshots show that it is using encryption, and you can view the self signed certificate.

![encryptionmethod](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/6067b28e-6d31-48ad-abca-91f094371869)
![selfsigned](https://github.com/thornburyjac/4980PrototypeSite/assets/111811243/2929ae6e-ebf4-475a-9e26-19609fdbb2b5)

- The current version of the site allows you to view the test images, view the cropped images, and download the test and cropped images.

# Part 4: Changing the website and server to authenticate "Obi Wan Kenobi"

- First, I am going to create a new site. Mostly copy pasting but since I want to make a landing/login page it just makes sense to me to start fresh.
- I will include the 7z archive of website2.7z in the WebsiteFiles directory.
- The new sites landing page will be a login page, where the shortened Leia message from A New Hope plays. Then there will be a obiwan page where the authenticated user has access to full site functionality and the full message from A New Hope plays.
