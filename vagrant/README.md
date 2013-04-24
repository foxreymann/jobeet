READ WHOLE FILE PLEASE!

0. Introduction

    This is software will help you to setup development environment in minutes without knowledge
    of sysadmin work and without caring about software configuration.

    In course of application development it will be updated to meet requirements. If you know about something
    neccessary and what is missing in current config, please add task to Trello.

    You can use this solution on Linux, Mac and even Windows (some necessary changes in Vagranfile are required).

1. Install necessary software:

    - Vagrant - http://www.vagrantup.com/
    - Git
    - VirtualBox (should be installed automatically by Vagrant)

   If you are using Linux:
    - NFS server (package nfs-kernel-server in Ubuntu)

2. Open terminal and run following command:

	vagrant box add precise64 http://files.vagrantup.com/precise64.box

    This will download Ubuntu 12.04 LTS image - system we use on Amazon EC2 for our app.

    If you don't run this command, necessary image file should be downloaded automatically during VM start

3. Clone V2 application repo somewhere in your filesystem

    cd /home/user/myworkspace
    git clone https://myuser@github.com/flooved/v2

4. Change current directory to vagrant and start virtual machine

    cd /home/user/workspace/v2/vagrant
    vagrant up

5. Edit files and open application using web browser and URL http://localhost:8080/

   Vagrant maps your folder (/home/user/myworkspace/v2 in this example) in virtual machine so every
   change you made in files in this folder are automatically visible in given URL. To be precise -
   webserver has root dir set to "public" subfolder.

6. Additional info

   - memcached listens on 127.0.0.1:11211

7. TIPS

    - some useful Vagrant commands (they must be run from vagrant subfolder)
	vagrant up	- creates and/or starts VM
	vagrant halt	- stops VM
	vagrant reload	- restarts VM
	vagrant destroy	- removes VM
	vagrant suspend	- freezes VM in current state
	vagrant status	- shows current VM state

    - when new version of Vargant configs is available, you have to pull recent changes from repo and run command
	    vagrant reload
	if you encounter problems try just stopping and starting VM
	    vagrant halt
	    vagrant up
	you can also install/update system dependencies by hand on running VM, but it's not necessary when using any of above commands
	    vagrant provision

    - you can access this VM shell by running
	    vagrant ssh
	or
	    ssh vagrant@localhost -p 2222

    - if you need access VM other than using "vagrant ssh", user and password for user with root privileges (using sudo) are:
	vagrant / vagrant

    - you can modify VM parameters (f.e. memory) by editing line in Vagrantfile
	vb.customize ["modifyvm", :id, "--memory", "1024"]

    - you can enable GUI for VM by adding "vb.gui = true" in Vagrantfile in virtualbox section

    - you can see logs from installation in /var/log/syslog within VM (lines marked vagrant.bootstrap)

    - other system images can be found at http://www.vagrantbox.es/
