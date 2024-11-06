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

```
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
- Need to setup the script to get all the files needed from the directory, not sure if we even need a for loop.
- Made this script and ran it, see output...

```text
thornbja@lappy:~/testaroo$ ./scrip2
Connected to 44.207.127.108.
sftp> put -r test* /var/www/html/authreq/images/baseimage
Uploading test1 to /var/www/html/authreq/images/baseimage/test1
test1                                                                                                                       100%    0     0.0KB/s   00:00
Uploading test2 to /var/www/html/authreq/images/baseimage/test2
test2                                                                                                                       100%    0     0.0KB/s   00:00
Uploading test3 to /var/www/html/authreq/images/baseimage/test3
test3                                                                                                                       100%    0     0.0KB/s   00:00
sftp> exit
thornbja@lappy:~/testaroo$ cat scrip2
#!/bin/bash

sftp -oIdentityFile=/home/thornbja/.ssh/prototype4980key.pem ubuntu@44.207.127.108 <<EOF
put -r test* /var/www/html/authreq/images/baseimage
exit
EOF

thornbja@lappy:~/testaroo$
```

- Confirmed the files showed up.
- So, the raspberry pi will transmit the files to a laptop. That laptop will then have all the images with specific names, ds## for example like ds01 and ds02. The script will then use the put -r ds** option to put all files starting with ds to the remote directory.

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

### Setting up the web server instance to use server side PHP logic
- Using [10] for reference.
- Ran `sudo apt-get update`
- Ran `sudo apt-get install php8.1-fpm -y`
- Ran `sudo systemctl status php8.1-fpm`
- Confirmed it installed, no errors and the service seems to be running.
- changed cropped.html to cropped.php and edited the contents to look like...

```text
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Image Gallery</title>
    <style>
        img {
            max-width: 100%;
            height: auto;
            margin: 10px;
        }
        .gallery {
            display: flex;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>
    <h1>Image Gallery</h1>
    <div class="gallery">
        <?php
        $dir = 'images/';
        $images = glob($dir . '*.{jpg,jpeg,png,gif}', GLOB_BRACE);
        
        foreach($images as $image) {
            echo '<img src="' . $image . '" alt="Image">';
        }
        ?>
    </div>
</body>
</html>

```

- Restarted nginx and php service.
- Navigated to the site, and now when I click the link it downloads the php file instead of displaying.
- Based on [10] I need to do more work within the nginx config file.

### Setting up the client cert on a phone
- I tried using the same pfx file that I used on my computer, but that does not seem to work.
- When I try to install it on my phone, it prompts me for a password which I remember setting but nothing seems to work.
- Similar outcomes on my group members phones.
- After some research found this [11]
- On the web server, ran this command `openssl pkcs12 -export -legacy -out phonetest.pfx -inkey testuser.key -in testuser.crt -certfile myca.crt`
- Entered the password for testuser.key
- Did not set a password for the output file.
- Now I have phonetest.pfx.
- As you can see, the only difference from my previous command that produced testuser.pfx was I added the -legacy option.
- Per my [11] source...

In the legacy mode, the default algorithm for certificate encryption is RC2_CBC or 3DES_CBC depending on whether the RC2 cipher is enabled in the build. The default algorithm for private key encryption is 3DES_CBC. If the legacy option is not specified, then the legacy provider is not loaded and the default encryption algorithm for both certificates and private keys is AES_256_CBC with PBKDF2 for key derivation.

- So based on that, it seems for the phones we tested they could not install the certificate if it was encrypted using the ciphers openssl uses without the -legacy option. When the -legacy option is set, the ciphers used create a pfx file that my phone at least can import.
- Tested the site. I was able to access both the landing page and the restricted section using my phone.
- Still need to fix the images page to scale using grid, but apart from that the client cert is working on a phone.

### Reproducing containerization issues
- Ran command `docker run -d --name nginx-container -e TZ=UTC -p 8080:80 ubuntu/nginx:1.18-22.04_beta`
- Ran command `docker exec -it nginx-container /bin/bash`
- The first command runs a test container using a preset image from dockerhub ubuntu/nginx:1.18-22.04_beta
- The second command allowed me to look around the containers files.
- It seems promising, looks more similar than the preset nginx image from dockerhub that uses alpine linux.
- Ran command `sudo docker ps -a` to view running containers.
- Ran command `docker stop $(docker ps -a -q)` in a root shell to stop all containers
- Ran command `docker rm $(docker ps -a -q)` in a root shell to remove all containers
- Created this Dockerfile in a directory on the AWS instance. All the necessary files, unless I am missing one, are in the directory with the Dockerfile like the site files and the config files and whatnot.
- Ran command `sudo docker build -t tester .` This should attempt to build an image called tester using the Dockerfile in the directory we are running the command in per the "."
- No errors.
- Ran command `sudo docker image ls`

ubuntu@4980webserv:~/dockertest$ sudo docker image ls
REPOSITORY     TAG               IMAGE ID       CREATED          SIZE
tester         latest            c88352f51439   53 seconds ago   385MB
ubuntu/nginx   1.18-22.04_beta   06f75a4c4bdf   7 weeks ago      149MB
hello-world    latest            d2c94e258dcb   18 months ago    13.3kB
ubuntu@4980webserv:~/dockertest$

- Now I just need to run a container from this image on the AWS instance.
- Ran command...

```text
docker run -d \
  --name site-container \
  -p 80:80 \
  -p 443:443 \
  -p 444:444 \
  tester
```
So the name of the container is site container. It exposes all the ports necessary for my configuration. The last line specifies the image to use for the container.
# IN FUTURE YOU NEED TO ADD SOME STUFF TO SETUP THE LINK BETWEEN THE FOLDERS THAT WILL HOLD THE DEATH STAR IMAGES

- Error...

```text
9f64252a584d08538657c74bc521e5b2595bd9b1ba411cb510fac94ef154b608
docker: Error response from daemon: driver failed programming external connectivity on endpoint site-container (fb0a419ea60a213f4e5ab139941def448b22f589684e5fba63320d2f9d4cad4f): failed to bind port 0.0.0.0:80/tcp: Error starting userland proxy: listen tcp4 0.0.0.0:80: bind: address already in use.

```

- Since I am on the AWS instance, nginx is already looking at those ports. Might need to create a new instance. Or I could just change the ports too...

```text
sudo docker run -d \
  --name site-container \
  -p 80:8080 \
  -p 443:4443 \
  -p 444:4444 \
  tester
```

- Tested the above command. Similar error referencing 443 instead of 80.
- Ran command `sudo systemctl stop nginx.service`. Maybe just stopping nginx for now will allow me to do this. tried...

```text
sudo docker run -d \
  --name site-container \
  -p 80:80 \
  -p 443:443 \
  -p 444:444 \
  tester
```

- So command runs, and it gives me the hash like the container ran, but then when I check I get this...

```text
ubuntu@4980webserv:~/dockertest$ sudo docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
4744c379ec7d   tester    "/docker-entrypoint.…"   27 seconds ago   Exited (1) 26 seconds ago             site-container

```

- Ran command `sudo docker logs -f site-container`

```text
ubuntu@4980webserv:~/dockertest$ sudo docker logs -f site-container
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
nginx: [emerg] SSL_CTX_load_verify_locations("/home/ubuntu/testclientcert/testuser.crt") failed (SSL: error:80000002:system library::No such file or directory:calling fopen(/home/ubuntu/testclientcert/testuser.crt, r) error:10000080:BIO routines::no such file error:05880002:x509 certificate routines::system lib)

```
- I forgot, in the config file it is looking for /home/ubuntu/testclientcert/testuser.crt for the user client cert auth, but I did not put that in my Dockerfile. Rectified and tried again.
- Setup this Dockerfile...

```text
# environment setup
FROM ubuntu/nginx:1.18-22.04_beta
RUN apt-get update
RUN apt-get install php8.1-fpm -y
RUN rm /etc/nginx/sites-available/default
COPY default /etc/nginx/sites-available/
COPY nginx-selfsigned.crt /etc/ssl/certs/
COPY nginx-selfsigned.key /etc/ssl/private/
RUN mkdir -p /home/ubuntu/testclientcert
COPY testuser.crt /home/ubuntu/testclientcert/

# put the site on there and make sure the perms are good
COPY html /usr/share/nginx/html
RUN chown -R www-data:www-data /usr/share/nginx/html
RUN chmod -R 750 /usr/share/nginx/html

# expose all the ports needed
EXPOSE 80
EXPOSE 443
EXPOSE 444
```

- When I run the container I still get the same issue, it looks like it starts but the site does not work and the container is stopped.
- Changed the default config file to look like ...

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
    ssl_client_certificate /etc/ssl/certs/testuser.crt;
    ssl_verify_client on;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    # Nginx php-fpm sock config:
    fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    # Nginx php-cgi config :
    # Nginx PHP fastcgi_pass 127.0.0.1:9000;
  }
}

```
As you can see now the user cert should be in /etc/ssl/certs/

- I changed the dockerfile to put the testuser.crt in the /etc/ssl/certs/ directory instead. Tried again.
- I am a fucking idiot. I am changing the Dockerfile but not rebuilding the image.
- Ran command `sudo docker rmi tester` to remove the image
- Ran command `sudo docker build -t tester .` to build another with the Dockerfile.
- Ran container and checked logs, see output...

```text
ubuntu@4980webserv:~/dockertest$ sudo docker run -d \
  --name site-container \
  -p 80:80 \
  -p 443:443 \
  -p 444:444 \
  tester
951752466f40740720ec4a3826c4998f8f4d5c036ae47a8ff9f72e2c4267df4f
ubuntu@4980webserv:~/dockertest$ sudo docker logs -f site-container
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```

- Now I am getting all sorts of nginx errors. So the container is running but the config to put up the site is porked.
- Making progress. Will come back tomorrow.

### More docker troubleshooting
- Alright, after some fiddling here is where i am at.

Dockerfile
```text
# environment setup
FROM ubuntu/nginx:1.18-22.04_beta
RUN apt-get update
RUN apt-get install php8.1-fpm -y
RUN rm /etc/nginx/sites-available/default
COPY default /etc/nginx/sites-available/
COPY nginx-selfsigned.crt /etc/ssl/certs/
COPY nginx-selfsigned.key /etc/ssl/private/
COPY testuser.crt /etc/ssl/certs/
RUN rm -R /var/www/html/*

# put the site on there and make sure the perms are good
COPY html /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 750 /var/www/html

# expose all the ports needed
EXPOSE 80
EXPOSE 443
EXPOSE 444
```

nginx config file in the container
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
    ssl_client_certificate /etc/ssl/certs/testuser.crt;
    ssl_verify_client on;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    # Nginx php-fpm sock config:
    fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    # Nginx php-cgi config :
    # Nginx PHP fastcgi_pass 127.0.0.1:9000;
  }
}
```

- When I create an image using that Dockerfile, and run this command...

```text
sudo docker run -d \
  --name site-container \
  -p 80:80 \
  -p 443:443 \
  -p 444:444 \
  tester
```

- I am able to start the container, it runs, and I am able to go to 44.207.127.108 in my browser and get the landing page. I then hit the link, enter the user/password/cert, and I get nginx forbidden error.
- Checked error logs, it seems I forgot the .htpasswd file.
- Updated Dockerfile to copy the .htpasswd file over.
- Now when I build the image and run the container, I can access the site, I can hit the link, it takes me to the restricted area with no auth prompt, and when I try to view the images I get bad gateway.
- Accessed container files once more to troubleshoot with `sudo docker exec -it site-container /bin/bash`
- See error log...

```text
root@02d53af3213c:/var/log/nginx# cat error.log
2024/11/06 11:35:54 [error] 18#18: *4 open() "/var/www/html/authreq/favicon.ico" failed (2: No such file or directory), client: 74.83.114.61, server: _, request: "GET /favicon.ico HTTP/1.1", host: "44.207.127.108:444", referrer: "https://44.207.127.108:444/"
2024/11/06 11:35:57 [crit] 18#18: *4 connect() to unix:/run/php/php8.1-fpm.sock failed (2: No such file or directory) while connecting to upstream, client: 74.83.114.61, server: _, request: "GET /cropped.php HTTP/1.1", upstream: "fastcgi://unix:/run/php/php8.1-fpm.sock:", host: "44.207.127.108:444", referrer: "https://44.207.127.108:444/"
2024/11/06 11:36:12 [error] 18#18: *4 open() "/var/www/html/authreq/favicon.ico" failed (2: No such file or directory), client: 74.83.114.61, server: _, request: "GET /favicon.ico HTTP/1.1", host: "44.207.127.108:444", referrer: "https://44.207.127.108:444/"
2024/11/06 11:36:27 [crit] 18#18: *4 connect() to unix:/run/php/php8.1-fpm.sock failed (2: No such file or directory) while connecting to upstream, client: 74.83.114.61, server: _, request: "GET /cropped.php HTTP/1.1", upstream: "fastcgi://unix:/run/php/php8.1-fpm.sock:", host: "44.207.127.108:444", referrer: "https://44.207.127.108:444/"
2024/11/06 11:36:27 [error] 18#18: *4 open() "/var/www/html/authreq/favicon.ico" failed (2: No such file or directory), client: 74.83.114.61, server: _, request: "GET /favicon.ico HTTP/1.1", host: "44.207.127.108:444", referrer: "https://44.207.127.108:444/cropped.php"
```

- I forgot to setup PHP in the Dockerfile? No its one of the first commands ran.
- Ran the container again, this time I get prompted for authentication so I do think that is working and before I was not prompted because some session crap or cookie or something.
- Same issue with the php.
- When I access the container with that exec command, and run `ps aux` to see services running I see this...

```text
root@863717729afb:~# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  1.4  56452 14208 ?        Ss   11:47   0:00 nginx: master process nginx -g daemon off;
www-data      18  0.0  0.9  56928  8828 ?        S    11:47   0:00 nginx: worker process
root          19  0.0  0.3   4628  3456 pts/0    Ss   11:49   0:00 /bin/bash
root          53  0.0  0.3   7064  2944 pts/0    R+   12:03   0:00 ps aux

```

- I dont see php running.
- Ran command `/etc/init.d/php8.1-fpm start`. This is because the running container cannot use systemctl for reasons I'm not sure of but have seen articles talking about why.
- That command uses the script in init.d to start php. Now when I run ps aux I see...

```text
root@863717729afb:~# sudo /etc/init.d/php8.1-fpm start
bash: sudo: command not found
root@863717729afb:~# /etc/init.d/php8.1-fpm start
root@863717729afb:~# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  1.4  56452 14208 ?        Ss   11:47   0:00 nginx: master process nginx -g daemon off;
www-data      18  0.0  0.9  56928  8828 ?        S    11:47   0:00 nginx: worker process
root          19  0.0  0.3   4628  3456 pts/0    Ss   11:49   0:00 /bin/bash
root          84  0.0  0.6 199716  6156 ?        Ss   12:08   0:00 php-fpm: master process (/etc/php/8.1/fpm/php-fpm.conf)
www-data      85  0.0  0.5 199716  5652 ?        S    12:08   0:00 php-fpm: pool www
www-data      86  0.0  0.5 199716  5652 ?        S    12:08   0:00 php-fpm: pool www
root          87  0.0  0.2   7064  2816 pts/0    R+   12:08   0:00 ps aux

```

- Might need to work this into the Dockerfile, now I will test.
- HUZZAH
- I changed the Dockerfile to have RUN /etc/init.d/php8.1-fpm start and I still get bad gateway when accessing the php file.
- I can still access the container though, run `/etc/init.d/php8.1-fpm start` and see that php is now started.
- So for some reason, `/etc/init.d/php8.1-fpm start` will work just in the running container, but does not seem to work when using `RUN /etc/init.d/php8.1-fpm start` in the Dockerfile.
- After some digging, remember that you had that little command at the end of your Dockerfile for Kayleighs project, it would look something like this for php...

```text
# PHP
# Set the default command to run PHP-FPM in the foreground
CMD ["php-fpm", "-F"]

# From kayleighs class project Dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

- I need to try this or research more into it....
- So, upon more research I added this `CMD service php8.1-fpm start && nginx -g "daemon off;"` to the bottom of the Dockerfile and that seems to work. There are more graceful ways to do it I am sure and if I have time I will refine it but this works for now.
- To summarize...

Dockerfile
```text
# environment setup. All these are dependencies, either files or services, needed
FROM ubuntu/nginx:1.18-22.04_beta
RUN apt-get update
RUN apt-get install php8.1-fpm -y
RUN rm /etc/nginx/sites-available/default
COPY .htpasswd /etc/nginx/
COPY default /etc/nginx/sites-available/
COPY nginx-selfsigned.crt /etc/ssl/certs/
COPY nginx-selfsigned.key /etc/ssl/private/
COPY testuser.crt /etc/ssl/certs/
RUN rm -R /var/www/html/*

# put the site files on there and make sure the perms are good
COPY html /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 750 /var/www/html

# expose all the ports needed for this configuration
EXPOSE 80
EXPOSE 443
EXPOSE 444

# ensure php AND nginx are running when the container starts
CMD service php8.1-fpm start && nginx -g "daemon off;"
```

Nginx config
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
    ssl_client_certificate /etc/ssl/certs/testuser.crt;
    ssl_verify_client on;
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    # Nginx php-fpm sock config:
    fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    # Nginx php-cgi config :
    # Nginx PHP fastcgi_pass 127.0.0.1:9000;
  }
}
```

List of all the dependencies in my docker folder for reference.
```text
ubuntu@4980webserv:~/dockertest$ ls -lah
total 36K
drwxrwxr-x 3 ubuntu ubuntu 4.0K Nov  6 20:33 .
drwxr-x--- 6 ubuntu ubuntu 4.0K Nov  6 20:33 ..
-rw-rw-r-- 1 ubuntu ubuntu   45 Nov  5 18:27 .htpasswd
-rw-rw-r-- 1 ubuntu ubuntu  793 Nov  6 20:33 Dockerfile
-rw-rw-r-- 1 ubuntu ubuntu 1.2K Nov  5 19:08 default
drwx------ 4 ubuntu ubuntu 4.0K Oct 17 12:58 html
-rw-rw-r-- 1 ubuntu ubuntu 1.3K Nov  5 18:24 nginx-selfsigned.crt
-rw-rw-r-- 1 ubuntu ubuntu 1.7K Nov  5 18:25 nginx-selfsigned.key
-rw-rw-r-- 1 ubuntu ubuntu 1.5K Nov  5 18:26 testuser.crt
```
html is a directory with the site files. default is the nginx config. the Dockerfile is shown above. the nginx-selfsigned files are for serving the site using https. testuser.crt is for client cert authentication. .htpasswd is for nginx simple authentication.

# TODO need to update the image with the newest site files. It currently is using the old php file that isnt styled right.

### Docker commands I use a lot
sudo docker stop site-container

sudo docker rm site-container

sudo docker rmi tester

sudo docker build -t tester .

**Run the container**
```
sudo docker run -d \
  --name site-container \
  -p 80:80 \
  -p 443:443 \
  -p 444:444 \
  tester
```

sudo docker images

sudo docker ps -a

sudo docker logs -f site-container

sudo docker exec -it site-container /bin/bash

### Lessons learned
- BTW /etc/init.d/php8.1-fpm start or /etc/init.d/php8.1-fpm restart is how you handle starting php service when you have a container that cant use systemctl. I imagine similar scripts exists for other services.

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

[10] What I used to get PHP working
https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/Nginx-PHP-FPM-config-example

[11] issue with importing certs on android
https://stackoverflow.com/questions/71872900/installing-pcks12-certificate-in-android-wrong-password-bug

[12] ubuntu with nginx on it preset image 
https://hub.docker.com/r/ubuntu/nginx
