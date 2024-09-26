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

### Notes/lessons learned

- Putting the root and index directive in the config file before the auth_basic directive means the website will allow you to access that section of the website without authentication.

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
