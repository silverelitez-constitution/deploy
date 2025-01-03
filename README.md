# Unified Automatic Cloud System

Currently testing on Centos 7 Core, Ubuntu 17.10.1, Gentoo 17.0-no-multilib

This is a Proof-Of-Concept project to develop a fully automated system that pays homage to the automatic transmission
in the way that can turn what is currently a very complicated and messy process to what most people don't even
give a second thought to. Thus turning a complete waste of resources and time into a way for the average engineer
to get more stuff done and not be tied up with menial tasks.

NEW! The translator system allows an administrator to run singular commands to interface with any distro. It works by aliasing/translating a list of commands to distro
specific commands. No more needing to look up what package manager or commands to use or even to read /etc/issue to figure out what to do. Computers are our butlers, let's
get the most out of our eager servants with as little effort as possible. That way, we can get more done with less unneeded effort.

The translator files are straight-forward. To add your distro, simply copy a translation file, fill in the variables/functions and issue a PR. We love your PR's!

It's currently being set up in the way that would be fully turn-key with an initial set up of 15 minutes (automated, naturally)
and the user only having to supply a domain name for the system to use. Authentication is still a little tricky due to the balance of
security and ease-of-use. Most likely a Yubikey will be implemented for initial/master authentication.

I'd like to reiterate that this _IS_ a _POC_. Despite this system being used to run and manage my network, it's NOT in 
ANY WAY meant to serve as a production deployment system. But instead, parts of this system that work very well are welcomed
to be adapted for your system as long as I get feedback on how it goes. :)

ALERT: Current scripts run/curl very slowly (mainly due to github throttling). A local caching solution or similar solution will be implemented to fix the issue

Quick Start
-----

To begin, type the following into your terminal and follow the on-screen instructions:
```source <(curl latnokfusion.org)```

How to execute deploy
-----

Run ./menu to navigate the virtual machine manager. Through this, you can add services, manage packages, configure default settings, and more.
The system is developed for initial configurations that will do everything needed to run a network. Be it a home LAN or an enterprise system, it can take care of it all.

You can manually spin up a service by cloning a box from the freshbox vm and changing the mac address. ssh into 
'freshbox' and change the '/etc/hostname' to the service name for the box. eg. webserver, dns-1, dns-2, dc, 
backup-dc, or ftp. reboot the box and once it's up, run 'deployer [service] [password] <optional hostnames>' and it 
should automatically do all the things required to prepare the service.

The menu system will automatically do all of those things, though.

Current deployer examples are as follows:
```deployer unifi mypassword123```
```deployer provisioner mypassword123 manager webserver ftp```
```deployer kodi mypassword123 media```

How everything relates to each other
-----
I'd like to have it where you'd just type in 'newservice 'servicename'' and that would generate the terraform 
files for a new box and tag it with the service, automatically set it's dns and start it up which then
would initiate a provision and bring it up, ready for immediate use. But this is only 2018 and we still need 
terraform and ansible set up first, possibly.

Set up process
-----

The vagrant-toolbox.sh script will get you set up. Once there, install the 
virtualbox plugin for terraform and create a sample box resource. For instance, something that can create the 
testing vm. since it's the testing vm, it doesn't matter if it's messed up. It's snapshotted and will be stored
on S3 soon. After that, use scripts to automate the process, feeding it only the service name. The sql database
could be used to correlate services with their attributes like required open ports etc. that'll come later. 
We're working within an enclosed sandbox for a reason right now. So then the base image needs to have
scripts inside it on boot that check if a provisioned flag was set in like /etc/flight.conf. If it's not
set, then run the deploy function using it's dns name. That will make it pull down the script that will install
all of it's things and then reboot it. once it's rebooted then it's ready to serve. that easy. "newservice 'unifi'"
and 4 minutes of waiting and BAM. That simple. The initial usb stick will just be a table of services where it
just cycles through the list running 'newservice' until everything is running. pre-configured. auto-managed.

To-Do
-----
- [x] set up dell optiplex for testing
- [x] configure raid
- [x] install centos 7 for vpc managment
- [x] configure initial services as VM's
- [x] router
- [x] bare centos 7 install (freshbox image)
- [x] samba4 domain controller
- [x] unifi
- [x] windows 8.1 test client
- [x] centos testing box
- [x] webserver 
- [x] write provisioner package
- [x] vpc host
- [ ] bind dns server
- [x] mysql server
- [ ] internal manager (and aws linking partner)
- [ ] centralized fileshare manager
- [ ] syslog server
- [x] link configs with github 
- [x] linux based active directory management tools (*not feasible)
- [x] configure deployment user and permissions 
- [x] unify the naming system
- [x] set up automatic deployment system
- [x] prune domain group policy (took 2 cases of redbull to complete)
- [ ] configure php function on webserver to detect curl requests
- [ ] refine modules and blocks to fit together better
- [x] think of another bullet point
- [x] terraform the virtualboxes
- [ ] set up aws system
- [ ] link router to aws router via openvpn
- [ ] set up BIND system
- [ ] configure ProBIND
- [ ] bridge dns with aws internal dns
- [ ] set up S3FS for configuration backup/storage
- [ ] set up gitFS to replace gitsource bash functions (possibly gluster as well)
- [ ] link krb on dc with 1password or similar
- [ ] NAS support (esata, lan, both?)
- [x] tie automation systems together
- [x] set up Nayrupanel
- [ ] reduce to 16gB initial payload for usb stick
- [ ] get some sleep
