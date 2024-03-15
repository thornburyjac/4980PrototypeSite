# Part 1: Using AWS CloudFormation to deploy the instance
- Log in to AWS using https://awsacademy.instructure.com/ CHECK THIS LINK
- In the search bar in the top right type "Cloudformation".
- Select "Create Stack with new resources".
- Select "Template is ready" and "Upload a template file".
- Select "choose file" and navigate to the yaml file provided then hit next.
- Give the stack a name, and select a key pair (KNOW WHAT KEY YOU ARE SELECTING, YOU WILL NEED IT TO ACCESS THE INSTANCE).
- Next through all the following screens, default settings are fine for testing.
- You should get a create complete message, if you did not then you will need to reassess the yaml and settings.
- The instance should be availabe to ssh into for configuration.

# Part 2: Configuring the instance
- You should be able to navigate to EC2 in AWS using the search bar, and see the instance. You can select the instance to view its IP address.
- Use ssh to access the instance for configuration. This command will allow you to remotely configure the instance "ssh -i /home/jacob/.ssh/labsuser.pem ubuntu@44.205.210.252".
- Breakind down the above command, ssh is the protocol you are using for remote access. The -i option allows you to specify the "identity file" which is the corresponding private key to the public key on the instance you selected in Part 1. Ubuntu@IP is the username you are logging in as on the host system which is the IP you specify.
- Once in the instance, verify the hostname changed and verify nginx is installed.
- You can use sftp on your local machine to dump the site files onto the instance using command "sftp -i /home/jacob/.ssh/labsuser.pem ubuntu@44.205.210.252". Pretty much same breakdown as the ssh command.
- Once in an sftp prompt, use the put <filename> command to "put" the file on the remote machine. Use pwd and lpwd to view remote and local working directory.
- Once the site files are on the instance, you need to put them in the directory that nginx serves html, which is /var/www/html. You should be able to do this with a command that looks like "sudo mv /home/ubuntu/4980_testsite /var/www/html/"
- You need to configure nginx to serve your site files instead of the default nginx files. Navigate to /etc/nginx/sites-available and edit the default file which is the config file.
- In the default config file there should be a line that looks like root /var/www/html;, change it to root /var/www/html/4980_testsite;
- Change permissions on the website files using commands "sudo chown -R www-data 4980_testsite" and "sudo chmod -R 750 4980_testsite" while in the /var/www/html directory.
- Restart and verify nginx is running after all thesee changes using "sudo systemctl restart nginx" and "sudo systemctl status nginx".
- Test site functionality by putting the IP address of the instance in the address bar of a web browser.

TODO CONFIGURE HTTPS
