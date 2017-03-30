# How to bootstrap a new CDE

## Introduction
This documentation will explain how you can create a new Centralized Deployment Environment, or CDE. A CDE is a set of machines and services that allow you to setup and manage cloud infrastructures.

## Services
There are two increments for each CDE, one is the core CDE and one is the
production CDE. The core contains the basic machines and services that you
need to actually bootstrap the rest of the pro


## Prerequisites
- /var/storage/repo-a1.cde.1nc/repos
- /var/storage/saltmaster-a1.cde.1nc/alchemy-saltstack_1.0-09.1_amd64.deb
- mac addresses for the virtual machines management interfaces need to be fixed

## Procedure
**Basic machine setup**
 - 00.cde_vm_init.sh
 - 01.cde_os_init.sh

**Masterless minion procedures**
 - 10.cde_stageone.sh minion
 - 10.cde_stageone.sh local
 - 10.cde_stageone.sh machine
 - 10.cde_stageone.sh miniverse

**Bring the new CDE core into shining state**
 - 20.cde_stagetwo.sh master
 - 20.cde_stagetwo.sh basic
 - 20.cde_stagetwo.sh shining

**Bring up the rest of the full CDE**
 - 30.cde_stagethree.sh maas
 - 30.cde_stagethree.sh ess-a2
 - 30.cde_stagethree.sh containers
 - 30.cde_stagethree.sh services

