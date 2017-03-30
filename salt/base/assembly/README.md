# Assemblies

Assemblies are orchestration states that do accept certain configuration options. This might be the **bootstrap** flag, telling the assembly that we are currently bootstrapping the CDE. Or passing a **scope** to the current environment.

The signature of the function to call is

`
assemble(target, topic, scope=None, saltenv='base', test=False, bootstrap=False, **kwargs)
`

## Bootstrapping the CDE
### Overview
To get a CDE up from nothing, you have to go through the following steps:

1. install an Ubuntu base system on ess-a1
2. copy the repositories folder to /var/storage/repo-a1.cde.1nc/repos
3. install the alchemy-saltstack package into ess-a1
4. run /srv/salt/cde/bootstrap/bash/01.cde_os_init.sh
5. optional: run /srv/salt/cde/bootstrap/bash/10.cde_stageone.sh scope
6. run /srv/salt/cde/bootstrap/bash/10.cde_stageone.sh salt
7. run all necessary assemblies to get the minimal bootstrap system up
8. use Maas to bring ess-a2 online
9. complete the installation of the CDE by installing all containers and services

### Basic steps
This is mostly self explanatory - you need an operating system on the machine and you dont have an automation environment yet. So you have to do it manually. You just need to install a basic system and ensure network connectivity. You need to make sure that your installation release is lower than the release you have in your repository. Otherwise you would introduce package versions newer to the ones you can install from your local repos and thus create unwanted variety.

After getting the os up you copy all the repository files onto this new machine. It will serve as the local repo later. If you keep the files on a USB drive or on another server on the network, use rsync to copy the files. But you need to take care of and **preseve** the massive amount of **hardlinks** in the aptly repo by using the **-H** flag.

`rsync -axiH --numeric-ids --delete [sourcepath] [root@target.machine:]/var/storage/repo-a1.cde.1nc/repos/`

Last step to get the basics done is to install the alchemy-saltstack package. This will put all automation files into the /srv directory. The packages needs to be installed using dpkg and you might find it in the repos you just copied.

`find /var/storage/repo-a1.cde.1nc/repos/aptly/public/cde -type f -name "alchemy-saltstack*.deb"`

If the file is not found try searching the parent directories - it will take longer but also search more sources. Once you have found the file, install it using

`dpkg -i [path_to_deb_file]`

### First automation steps - bootstrap phase
You now need to run the so called bootstrap phase. This phase aims to complete the setup of the salt-master and the master's salt-minion, deploy containers for dns, dhcp and repos and install their services. This phase will also install and configure the maas container and service.

First you run the cde_os_init script to create a few files and temporary settings needed in this phase. It will make your local repos available to salt states using a basic python webserver and set the hosts and apt configuration file to point to this host's IP address.

`/srv/salt/cde/bootstrap/bash/01.cde_os_init.sh`

Next, you optionally set a scope for the environment you are going to install. This will be put into the alchemy-scope default file and reflected in the salt masters setup.

`/srv/salt/cde/bootstrap/bash/10.cde_stageone.sh scope`

Now you install the salt system by running the salt target for the stageone script. You will end up with a fully functional salt system and you can proceed by only using salt powers.

`/srv/salt/cde/bootstrap/bash/10.cde_stageone.sh salt`

We need to install three containers and their services:
- micros-a1 for dhcp and dns
- repo-a1 for files and repos
- maas-a1 for maas - as this one needs the other services to be up its setup is done last

For this step, run the following command:

`salt-run alchemy.assemble ess-a1.cde.1nc cde.bootstrap bootstrap=true scope=bbox`
`salt-run alchemy.assemble ess-a1.cde.1nc common.baseline bootstrap=true scope=bbox`


and now
