# Optimizing the 4980 Prototype Site and Github Repo

## Overview

After the initial process of creating the prototype site (see README_OLD.md for more details) I decided to optimize the design. My goals are in no paticular order...
- Implement multi-factor authentication on the site. I still intend on using the builtin nginx simple password functionality coupled with certificate based authentication.
- Containerize the whole part of this project. That way all we have to do is put up an EC2 instance and run a container on it that has all the functionality and config files just containerized.
- Per the issue where the nginx authentication is kicking off on the landing page, when it should only be kicking off on the authenticated page, maybe implement two web servers. One for the landing page and one for the authenticated users. That or figure out how to seperate the two on one server.
- Organize the Github.

At the end of the process, the site and its infrastructure should be...
- Publicly accessible.
- Utilize mfa.
- Have a landing page that displays only the shortened video message, with an option to authenticate as Obi Wan.
- Once authenticated, the page will display the whole video messsage plus the Death Star plans, both the original images and the vulnerabilities.
- The Github won't be a mess.
- The whole site will be containerized. That way deploying it will be as simple as a yaml file that creates the infrastructure on AWS and then runs the appropriate container(s).
- This README and the old README will be renamed and reorganized into something like process documentation. The proper README will just give an overview of the functionality and Github organization.

I have not been working on this project all Summer, so I will need to setup my environment again and basically start fresh, only using the README_OLD file to get back to where I was.

## Process documentation

### Environment setup
*This is basically the steps I took to get to where I was at last semester.*

- Installed MobaXterm and WSL for Ubuntu.
- Error whenever Ubuntu was installing.
- Navigated to Windows Features and turned on Windows Subsystem for Linux.
- I am now able to open MobaXterm, and open Ubuntu terminal instances in it.

![image](https://github.com/user-attachments/assets/457b8415-2411-4685-bc4b-cb74efb0c95d)

- I now need to basically get to where I had left off at the end of last semester. To do this I will need to utilize the README_OLD.md file.
- First issue I think is the key pair. In the past I used the key that I had setup for another class, now I need to setup my own.
- Navigated to AWS [2] > EC2 > Key Pairs > Create key pair.
- Created the "prototype4980key"
- Type is .pem
- Tag is Key: prototype4980keytag and Value: proto
- Opened Terminal on my local machine lappy.
- Created `/home/thornbja/.ssh` directory
- Created `prototype4980key.pem` file and pasted the private key in there.
- That should be good now to ssh into an EC2 instance created with that key pair in mind.
- Navigated to AWS [2] > CloudFormation > Create stack with new resources.
- Selected to upload a template file.
- Used the 4980_webserv.yml file which is in the /4980PrototypeSite/YAML folder of this repo
- Named the stack `prototype4980stack1`
- Left everything else default and submitted the stack creation.
- Create complete message from CloudFormation
- Instance IP is `44.207.127.108`
- Input command `ssh -i /home/thornbja/.ssh/prototype4980key.pem ubuntu@44.207.127.108`
- terminal just seems to hang.
- Input command `sudo chmod 700 prototype4980key.pem` to ensure correct permissions on key.
- Issue persists.
- Not sure if this is the issue, but the security groups that were set in the YAML file used my old public IP address, it has changed since then.
- Navigated to AWS > EC2 > Security Groups.
- Edited the inbound rules for my new IP address. Now I should be able to SSH from my home network into the instance.
- That was the issue, always remember permissions issues.
- Now I can run `ssh -i /home/thornbja/.ssh/prototype4980key.pem ubuntu@44.207.127.108` and I am prompted to add it to known hosts.

![image](https://github.com/user-attachments/assets/f98cb9a4-201e-4c16-a280-ad07fca187aa)

- Confirmed nginx was installed as well.
- Downloaded TestSite2.7z from the WebsiteFiles folder in this repo.
- Put it into my virtual Ubuntu machine in the home directory for thornbja /home/thornbja.
- Ran `sftp -i /home/thornbja/.ssh/prototype4980key.pem ubuntu@44.207.127.108`
- Now I am in a file transfer session.
- Using pwd I can view the working directory of the remote EC2 instance. Using lpwd command I can view my local machine working directory.
- Used command `put TestSite2.7z` to put the website files on the remote machine.
- Confirmed the 7z file was on the remote webserv instance.
- Ran `sudo apt-get update` to ensure apt was up to date.
- Ran `sudo apt-get install p7zip-full` to install 7z on webserv.
- Ran `7z x TestSite2.7z` to extract website files onto the machine.
- Ran `sudo mv TestSite2 /var/www/html/`
- Navigated to /var/www/html/
- Ran `sudo chown -R www-data TestSite2`
- Ran `sudo chmod -R 750 TestSite2/`
- Ran `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt`
- Navigated to /etc/nginx/sites-available
- Removed the default config file, replaced it with my own...

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

- Ran `sudo systemctl restart nginx.service`
- Ran `sudo systemctl status nginx.service`
- Service appears to be running correctly.
- From my browser, navigated to https://44.207.127.108/
- Nginx not found error.
- I think the issue is I forgot to change the default location to look for index in the config file, in the one above it is set to look at 4980_testsite where in this case it is /var/www/html/TestSite2
- Made the alteration to the config file.

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
        root /var/www/html/TestSite2;
        index index.html;
    }
}
```

- Restarted Nginx.service again.
- From my browser, navigated to https://44.207.127.108/ and confirmed I was able to access the site using HTTPS.
- Confirmed HTTP redirected to HTTPS.
- Installed apache utils which is needed for nginx password auth using `sudo apt install apache2-utils`
- Ran `sudo htpasswd -c /etc/nginx/.htpasswd obiwan` which should create the necessary file for nginx simple auth, and create the user obiwan, and then prompt me to create a password.
- Added user successfully, see landing page for password hint.
- Navigated to /etc/nginx/sites-available
- Using :%d in vim to remove the contents of default.
- Pasted the new config file from the nginx simple authentication part of the README_old.md file.
- The config file is now...

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
        root /var/www/html/TestSite2;
        index index.html;
    }

    # Location blocks for restricting access to specific paths
    location /obiwan.html {
        root /var/www/html/TestSite2;
        index index.html;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location /scripts {
        root /var/www/html/TestSite2;
        index index.html;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location /styles {
        root /var/www/html/TestSite2;
        index index.html;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location /images {
        root /var/www/html/TestSite2;
        index index.html;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location /cropped.html {
        root /var/www/html/TestSite2;
        index index.html;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location /base.html {
        root /var/www/html/TestSite2;
        index index.html;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

- Restarted nginx to confirm functionality.
- Now I need to turn off basic auth on the landing page.
- Per some online articles, if I add this line `auth_basic          off;` to the config file in the location blocks I dont want authenticating that might work.
- I tried a few different ways, I think I need to restructure the website. All the html files, like index.html, obiwan.html, etc are in the root directory. Maybe I need to restructure the site to have those in other folders.
- Look into this documentation [3]
- After looking into [3] and [4] here is the config file that is half working...

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
                root /var/www/html;
                try_files $uri $uri/ =404;
        }
        location /authreq {
                try_files $uri $uri/ =404;
                auth_basic "Restricted";
                auth_basic_user_file /etc/nginx/.htpasswd;
        }
}

```

- This config file allows you to go to the home page without being prompted for a password.
- You can then click the link and get prompted for a password, but after entering it in I get a not found error.
- After much restructuring, and many nginx config files, I think I have landed on the configuration that works.
- Uploading 1FAwebsitefiles to the /WebsiteFiles directory. This is the directory structure that so far is working with the nginx config file.
- See below for the nginx config file that is working...
  
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
                root /var/www/html;
                try_files $uri $uri/ =404;
        }
        location /authreq {
                auth_basic "Restricted";
                auth_basic_user_file /etc/nginx/.htpasswd;
                root /var/www/html;
                index obiwan.html;
        }
}
```

- Remember this config file will only work if the self signed certificate is generated and in the right place for HTTPS. And the htpasswd file is generated, in the right place, and has a user/password setup.

### Implementing multi-factor authentication using client side certificates documentation
- Following reference [5], I will try to implement multi-factor authentication using client side certificates.
- Created directory /home/ubuntu/testclientcert
- Ran command `openssl genrsa -des3 -out ca4980.key 4096`, used the same passphrase the site uses.
- Ran command `openssl req -new -x509 -days 365 -key ca4980.key -out ca4980.crt`, entered passphrase for the ca4980.key, and left every cert field blank.
- Ran command `openssl genrsa -des3 -out user.key 4096`, entered same passphrase I used for the site.
- Ran command `openssl req -new -key user.key -out user.csr`, entered the passphrase for the user.key. Left every cert field blank.
- Remember, look at [5] for descriptions of what these commands are doing.
- Ran command `openssl x509 -req -days 365 -in user.csr -CA ca4980.crt -CAkey ca4980.key -set_serial 01 -out user.crt`
- Entered all the passphrases it needed, and the passphrase I entered for this file is the same as for the website.
- As I understand it, this is the file that would need to be added to the client machine that it would use for authentication.
- Navigated to the nginx config file, and added the line `ssl_client_certificate /home/ubuntu/testclientcert/ca4980.crt;` to the server block.
- Transferred pfx file to local machine.
- Imported into firefox by navigating to settings > privacy and security > scrolling down and selecting view certificates > importing to the your certificates tab.
- Restarted nginx service on my webserv to be safe.
- Navigated to site in incognito tab to ensure no cookies would cause problems.
- I was able to access the site, but so was someone who did not have the certificate.
- Added `ssl_verify_client on;` line to the server block in the config file.
- Double clicked on the .pfx file I put on my local machines desktop to run through the import wizard.
- Ensured the cert was imported in the same place I put it last in Firefox.
- Tried to access the site again in incognito.
- Received error...

![image](https://github.com/user-attachments/assets/89119632-e93f-4a4b-9198-40943aec8100)

- I was prompted for the cert though.
- Tried in a regular tab.
- Same error, need to work the error now as at least now it is prompting for the certificate.

### Implementing multi-factor authentication using client side certificates documentation again
- Perhaps I made a mistake in one of the many steps it took to setup the cert auth, I am trying again this time using another guide [6]
- Navigated to /home/ubuntu/testclientcert
- Changed permissions on this directory based on [6].
- Ran command `openssl genrsa -des3 -out myca.key 4096` and used the same passphrase I use for everything related to this project.
- Ran command `openssl req -new -x509 -days 3650 -key myca.key -out myca.crt` and entered the passphrase for myca.key. Left everything in the cert blank.
- Ran command `openssl genrsa -des3 -out testuser.key 2048` and set default passphrase.
- Ran command `openssl req -new -key testuser.key -out testuser.csr`, entered passphrase for testuser.key, and left every cert detail field blank.
- Ran command `openssl x509 -req -days 365 -in testuser.csr -CA myca.crt -CAkey myca.key -set_serial 01 -out testuser.crt`
- Ran command `openssl pkcs12 -export -out testuser.pfx -inkey testuser.key -in testuser.crt -certfile myca.crt`
- Used sftp to transfer the pfx file to my machine.
- Ran through cert install wizard on my machine.
- Added cert in firefox settings.
- HUZZAH
- Tried again in incognito window.
- HIP HIP, HUZZAH.
- So this above process should work, use [6] for reference.

Here is what the config file looks like...
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
    ssl_client_certificate /home/ubuntu/testclientcert/testuser.crt;
    ssl_verify_client on;

    # Other SSL configuration directives can go here

        location / {
                root /var/www/html;
                try_files $uri $uri/ =404;
        }
        location /authreq {
                auth_basic "Restricted";
                auth_basic_user_file /etc/nginx/.htpasswd;
                root /var/www/html;
                index obiwan.html;
        }
}

```

- Also I took a snapshot of the EC2 instance as it is right now snap-0abd9eb859bf66b65 in AWS.
- Now all that is left is to figure out how to have it only prompt for the authenticated part of the site and not the whole site.

### Fixing multi-factor authentication to only prompt on the restricted portion of the site.
- Set an entry on my Windows machine hosts file so the EC2 instance IP corresponds with the domain name www.4980bullshit.com
- When you go to the restricted portion of the site, the URL is https://www.4980bullshit.com/authreq/obiwan.html
- So could I set multiple server blocks in the nginx config file to correspond with those different URLS or parts of the site?
- [7] might be useful, forum on multiple server blocks for same IP.
- Perhaps having the landing page be served up on port 443, but the restricted site be served up on some arbitrary port. That way I can have different server blocks for the same IP, just one server block for each port.
- So after thinking about it, I made a few changes to the config and we are slightly working.
- First, in index.html, changed the link to be `https://44.207.127.108:444`
- In AWS, setup a new inboud rule in the security group to allow all traffic to port 444.
- Setup the config file to be...

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
                root /var/www/html;
                try_files $uri $uri/ =404;
        }
}

server {
    listen 444 ssl;
    listen [::]:444 ssl;
    server_name _;

    root /var/www/html/authreq;
    index obiwan.html;


    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_client_certificate /home/ubuntu/testclientcert/testuser.crt;
    ssl_verify_client on;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

- Now when you go to the site, everyone can access the homepage, but hitting the link at the bottom prompts for the mfa.
- I am able to authenticate but this is what I get...

![image](https://github.com/user-attachments/assets/9aff03c3-a288-4143-be94-b41090f89e34)

- Checked the error.log with `sudo cat /var/log/nginx/error.log`
- See this line `2024/10/01 12:38:23 [error] 21963#21963: *5 open() "/var/www/html/authreq/styles/obiwan-style.css" failed (2: No such file or directory), client: 130.108.104.139, server: _, request: "GET /styles/obiwan-style.css HTTP/1.1", host: "44.207.127.108:444", referrer: "https://44.207.127.108:444/"`
- As you can see it is looking for /var/www/html/authreq/styles/obiwan-style.css in the wrong folder since in the config file I specified root in both server blocks. The correct css path should be /var/www/html/styles/obiwan-style.css
- Now I get a default nginx forbidden error.
- Checked error log again.
- Decided to keep the config file as is, and just move the css to where nginx is looking, basically create a new directory.
- Created a new styles directory and created all the corresponding styles files in /var/www/html/authreq/styles
- Now any user can reach the landing page, when they select the link they are prompted for mfa, and when they correctly authenticate the site css works.
- Now I just need to restructure the site one more time, basically lock everything but the landing page in the authreq folder, including the images, and update all the links in all the html documents.

this is what the config file looks like
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
                root /var/www/html;
                try_files $uri $uri/ =404;
        }
}

server {
    listen 444 ssl;
    listen [::]:444 ssl;
    server_name _;

    root /var/www/html/authreq;

    index obiwan.html;


    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_client_certificate /home/ubuntu/testclientcert/testuser.crt;
    ssl_verify_client on;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

- And the site structure is all changed so I need to restructure it, update all the links, then I will add a new version in the websitefiles directory in this repo.
- I restructured the site, and Matt is finishing his container for the 1fa version of the site.
- At this point he has a container running that serves up the working 1fa version of the site. He also has a folder on his local machine linked to the container, so we can dump images into that folder and they will populate in the container in the /images folder.
- At this juncture the next step is providing Matt with the files for the 2fa version of the site, and further cementing my understanding of how the actual test will go. The site will be up, with no images. After we receive the images we will put them in the linked folder with the container and those will appear on the site after a refresh. So I need to figure out a naming convention for the images so I can properly link them, and I need to figure out how to transfer the images from the computer that receives them to the EC2 instance.

### Setting up a script to transfer the files to the EC2 instance

- Using [8] and chatgpt, I created this script...

```text
#!/bin/bash

sftp -oIdentityFile=/home/thornbja/.ssh/prototype4980key.pem ubuntu@44.207.127.108 <<EOF
put test1
put test2
put test3
exit
EOF

```

- And it worked!

![image](https://github.com/user-attachments/assets/0230eee6-8574-4934-9266-c4124187bda6)

- I verified my three test files appeared on the ec2 instance.
- I probably want to make the script more complex by just having a for loop iterate through the directory and take all the files and put them where they need to go.
- I also need to make sure the script on my local machine has permissions to put the files where they need to go.

```text
#!/bin/bash

sftp -oIdentityFile=/home/thornbja/.ssh/prototype4980key.pem ubuntu@44.207.127.108 <<EOF
put test1 /var/www/html/authreq/images/baseimage
put test2 /var/www/html/authreq/images/baseimage
put test3 /var/www/html/authreq/images/baseimage
exit
EOF

```

- Tried this script and got permission denied errors.

![image](https://github.com/user-attachments/assets/214e00e8-1610-4d21-9873-de0200242341)


- I need to give the ubuntu user more rights to that location.
- Ran `sudo chgrp -R www-data html` and `sudo chmod -R 770 html`
- Ran `sudo usermod -a -G www-data ubuntu`
- The ubuntu user should be in the www-data group now, and the www-data group members should have access to all the files for the website. Now when I run scrip it should not get a permissions error.
- Ran the script, and confirmed the test files showed up in /var/www/html/authreq/images/baseimage


### Installing docker on the ubuntu instance in preparation to test the containerized version of the site/service
- Using [9] as reference
- Ran all these commands...

```text
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

- No errors.
- Then ran all this...

```text
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

- No errors.
- Ran command `sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
- Should be good? Ran `sudo docker run hello-world` to test
- Confirmed Docker appears to be working correctly.

### Notes/lessons learned

## References

[1] Might help me solve the issue where the landing page is prompting for authentication where it should only be the second page.
https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/

[2] AWS
https://us-east-1.console.aws.amazon.com/console/home?region=us-east-1

[3] nginx how to process request
https://nginx.org/en/docs/http/request_processing.html

[4] video on basic auth
https://www.youtube.com/watch?v=_zoDkXyXrx4

[5] Article I used to try client side certs the first time around
https://fardog.io/blog/2017/12/30/client-side-certificate-authentication-with-nginx/

[6] Another guide on client side certs
https://www.ssltrust.com/help/setup-guides/client-certificate-authentication

[7] Multiple server blocks
https://stackoverflow.com/questions/11773544/nginx-different-domains-on-same-ip

[8] script to transfer files to ec2 instance research
https://superuser.com/questions/1566901/how-do-i-connect-to-sftp-with-provided-ssh-key

[9] installing docker on ubuntu
https://docs.docker.com/engine/install/ubuntu/


