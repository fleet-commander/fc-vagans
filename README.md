Vagrant + Ansible for FleetCommander
====================================

Authors:
    Fabiano Fidêncio <fidencio@redhat.com>
    Oliver Gutierrez <ogutierrez@redhat.com>

This playbook is a modified for fork of Christian Heimes' pki-vagans
https://github.com/tiran/pki-vagans

Requirements
============

The setup needs about 3.5 GB of free RAM and 25 GB disk space.

Install dependencies
--------------------

```shell
sudo dnf install ansible libvirt vagrant vagrant-libvirt vagrant-hostmanager libselinux-python nss-tools
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo usermod -G libvirt -a YOUR_USER
```


Either restart your session or use newgrp to join the new user group
(current shell only).

```shell
$ newgrp libvirt
```

passwords
=========

The default password for the users root and vagrant, FreeIPA's admin user is **Secret123**. The Directory Manager password is **DMSecret456**.


FleetCommander
==============

```shell
$ cd fleet-commander
$ ./setup.sh
```

Vagrant's multi-machine setup can run into a race condition and starts
provisioning before all machines have a new SSH key.
```vagrant up --no-provision``` followed by ```vagrant provision``` is more stable.
Sometimes the initial provision fails to configure the client. A second provisioning run with ```vagrant provision``` fixes most issues.

The FleetCommander playbook deploys two machines:

  * ipamaster (master.ipa.example)
  * ipaclient (client.ipa.example)

When the machines are up, you can acquire a Kerberos ticket and start a local
instance of Firefox to explore the WebUI. The admin password is **Secret123**.

```shell
$ bin/ipa_kinit admin
$ bin/ipa_firefox
$ bin/ipa_ssh admin@client.ipa.example
```

Vagrant quick manual
====================

create VM
---------

```shell
$ cd fleet-commander
$ vagrant up
```

Provision the VM again
----------------------

For example to update RPMs

```shell
$ vagrant provision
```

Log into VM
-----------

```shell
$ vagrant ssh <machine>
```

Destroy VM
----------

```shell
$ vagrant destroy
```

Install custom RPMs
-------------------

Copy or symlink files or directories with RPMs into pki/rpms or
ipa/rpms and set custom_rpms to True. The Ansible playbook will pick up all
RPMs (even in symlinked and nested directory structures) and install them.

When something fails
--------------------

```shell
$ sudo systemctl restart libvirtd.service
$ vagrant provision
```

Ansible roles
=============

bootstrap
---------

General bootstrapping tasks to set up networking and Ansible dependecies (Python 2).

common
------

Common tasks for FreeIPA:

 * firewalld
 * SELinux
 * rngd
 * time zones
 * hosts

ipa
---

FreeIPA base package and common facts

ipa-client
----------

Configure host as FreeIPA client

ipa-inventory
-------------

Create local configuration files and scripts for kinit, ssh and Firefox

ipaserver
---------

Install FreeIPA server packages

ipaserver-master
----------------

Set up FreeIPA master
