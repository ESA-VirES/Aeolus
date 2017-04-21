# VirES for Aeolus
VirES for Aeolus - installer and utilities

This repository contains the installation and configuration scripts of the
VirES for Aeolus system.

The repository contains following directories:

-  `scripts/` - installation scripts
-  `contrib/` - location of the installed SW packages
-  `vagrant/` - vagrant VirES for Aeolus server development machine

NOTE: The repository does not cover the autonomous Cloud-free Coverage
Assembly.

### Installation

In this section the VirES for Aeolus installation is described.

#### Prerequisites

The installation should be performed on a *clean* (virtual or physical)
CentOS 7 machine. Although not tested, it is assumed that the installation
will also work on the RHEL 7 and its other clones.

The installation requires access to the Internet.

The installation scripts may search for some the SW installation packages
in the `contrib/` directory and if not found they try to download the SW
packages form the predefined location. As not all SW packages are available
on-line some of the SW packages might need to be copied manually
and put in the `contrib/` directory beforehand.

(Currently, the built web client needs to be copied manually. More details TBD.)


#### Step 1 - Get the Installation Scripts

The installer (i.e., content of this repository) can be obtained
either as on of the [tagged
releases](https://github.com/ESA-VirES/Aeolus/releases)
or by cloning of the repository:

```bash
git clone https://github.com/ESA-VirES/Aeolus.git
```

#### Step 2 - Prepare the installed SW packages

Put the SW packages which cannot be downloaded automatically
to the `Aeolus/contrib/` directory.

#### Step 3 - Run the Installation

Execute the installation script with the root's permission:

```bash
sudo Aeolus/scripts/install.sh
```

The output os the `install.sh` command is automatically saved to a log file
which can be inspected in case of failure.

```bash
less -rS  install.log
```

The `install.sh` command executes the individual installation scrips
located in the `scripts/install.d/` directory:

```bash
ls Aeolus/scripts/install.d/
00_selinux.sh    20_apache.sh         30_eoxs_rpm.sh
05_limits.sh     20_django.sh         30_vires_rpm.sh
10_rpm_repos.sh  20_gdal.sh           31_eoxs_wsgi.sh
15_curl.sh       20_mapserver.sh      45_client_install.sh
15_jq.sh         20_postgresql.sh     50_eoxs_instance.sh
15_unzip.sh      25_spacepy.sh        55_client_config.sh
15_wget.sh       30_eoxmagmod_rpm.sh  70_eoxs_load_fixtures.sh
```

By default, all these installation scripts are executed in order given by the
numerical prefix. However, the `install.sh` command allows execution of
the explicitly selected scripts as, e.g., in following command
(re-)installing and (re-)configuring the EOxServer instance:

```bash
sudo Aeolus/scripts/install.sh
Aeolus/scripts/install.d/{50_eoxs_instance.sh,70_eoxs_load_fixtures.sh}
```

This allows installation and/or update of selected SW packages only.



### Aeolus-Server Development Environment

The repository provides a vagrant machine to quickly set up a development
instance of the VirES for Aeolus server.

#### Step 1 - Clone the Required Repositories

```bash
git clone git@github.com:ESA-VirES/Aeolus.git
git clone git@github.com:ESA-VirES/Aeolus-Server.git
git clone git@github.com:EOxServer/eoxserver.git
git clone git@github.com:EOxServer/eoxs-allauth.git
```

Switch branch of eoxserver
```bash
cd eoxserver
git checkout 0.4
git pull
```

Currently, the built web client needs to be copied manually to the `contrib`
directory:

```bash
cp WebClient-Framework.tar.gz VirES/contrib/
```

#### Step 2 - Customisation

The custom configuration option to be applied to your Vagrant instance can
be put in the optional `Aeolus/scripts/user.conf` file. The environment
variables defined in this file will override the installation defaults.

Example `user.conf`:
```
CONFIGURE_ALLAUTH=YES
TEMPLATES_DIR_SRC="/usr/local/vires-dempo_ops/templates"
FIXTURES_DIR_SRC="/usr/local/vires-dempo_ops/fixtures"
```

#### Step 3 - Start the Vagrant Machine

```bash
cd Aeolus/vagrant
vagrant up
vagrant ssh
```

#### Quick Start

To access the server use following URLs:

```
http://localhost:8400
http://localhost:8400/eoxs
http://localhost:8400/eoxc
```
