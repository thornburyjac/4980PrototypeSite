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

### 

## Notes/lessons learned

## References

[1] Might help me solve the issue where the landing page is prompting for authentication where it should only be the second page.
https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/

[2] AWS
https://us-east-1.console.aws.amazon.com/console/home?region=us-east-1
