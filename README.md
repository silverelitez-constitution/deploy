# deploy

TO DO 
-----
[]Explain how to execute deploy

currently you'd manually do it by cloning a box from the freshbox vm and changing the mac address. ssh into 
'freshbox' and change the '/etc/hostname' to the service name for the box. eg. webserver, dns-1, dns-2, dc, 
backup-dc, ftp. reboot the box and once it's up, ssh in, sudo su -, and then run 'deploy "service"' and it 
should automatically do all the things

[]Explain how everything relates to each other
i'd like to have it where you'd just type in 'newservice 'servicename'' and taht would generate the terraform 
files for a new box and tag it with the service, automatically set it's dns and start it up which then
would initiatie a provision and bring it up, ready for immediate use. but this is only 2018 and we still need 
terraform and ansible set up

[]Properly document set up process
in your own personal home directory, git clone (currently deleted the repo because i need it to be private which 
requires a paid github account. i think i can swing it, though, later today). it's currently on your laptop in 
my home directory under "flight". the vagrant-toolbox.sh script will get you set up. once there, install the 
virtualbox plugin for terraform and create a sample box resource. for instance, something that can create the 
testing vm. since it's the testing vm, idc what the hell happens to it. after that, use scripts to automate the 
process, feeding it only the service name. the sql database could be used to correnlate services with their 
attributes like required open ports etc. that'll come later. we're working within an enclosed sandbox for a 
reason right now. so then the base image needs to have scripts inside it on boot that check if a provisioned 
flag was set in like /etc/flight.conf. if it's not set then run the deploy function using it's dns name. that 
will nmake it pull down the script that will install all of it's things and then reboot it. once it's rebooted 
then it's ready to serve. that easy. "newservice 'dns'" and 4 minutes of waiting and BAM. that simple. the 
initial usb stick will just be a table of services where it just cycles through the list runnign 'newservice'
until everything is running. pre-configured. auto-managed.
