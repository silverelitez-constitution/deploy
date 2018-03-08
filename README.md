# Unified Automatic Cloud System

This is a Proof-Of-Concept project to develop a fully automated system that pays homage to the automatic transmission
in the way that can turn what is currently a very complicated and messy process to what most people don't even
give a second thought to. Thus turning a complete waste of resources and time into a way for the average engineer
to get more stuff done and be tied up with menial tasks.

It's currnetly being set up in the way that would be fully turn-key with an initial set up of 15 minutes (automated, naturally)
and the user only having to supply a domain name for the system to use. Authentication is still a little tricky due to the balance of
security and ease-of-use. Most likely a Yubikey will be implemented.

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

Currently you'd manually do it by cloning a box from the freshbox vm and changing the mac address. ssh into 
'freshbox' and change the '/etc/hostname' to the service name for the box. eg. webserver, dns-1, dns-2, dc, 
backup-dc, or ftp. reboot the box and once it's up, run 'deployer [service] [password] <optional hostnames>' and it 
should automatically do all the things required to prepare the service.

Current deployer examples are as follows:
```deployer unifi mypassword123 unifi```
```deployer dc-client-auth mypassword123 manager webserver ftp```
```deployer kodi mypassword123```

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
set, then run the deploy function using it's dns name. That will nmake it pull down the script that will install
all of it's things and then reboot it. once it's rebooted then it's ready to serve. that easy. "newservice 'dns'"
and 4 minutes of waiting and BAM. That simple. The initial usb stick will just be a table of services where it
just cycles through the list running 'newservice' until everything is running. pre-configured. auto-managed.
