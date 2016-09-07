Getting Started
===============

This document contains the complete instructions to get up and running. If this is your first time using the project run through this guide and you should be good to go. :)

Installation
------------

The following covers (or links to) the installation of all the required tools/software. Go through the list in order, if certain steps have already been completed then they may be skipped (assuming correct version). Just follow the steps for your system.

### 0. Pre-Install

If following any of the quick suggested installation instructions, these steps may require additional tools/package managers or environment settings. The following will outline any of these non-project relevant installation instructions.

#### Debian/Ubuntu Linux

Assumes you are using the apt package manager. This should be the default package manager on the system.

#### Mac OS X

Assumes you are using the Homebrew package manager. If you do not have this package manager already installed, it can be installed by following the instructions at: http://brew.sh

Alternatively if you use another package manager like MacPorts, these brew commands can usually be substituted with the equivalent `sudo port install` command. As the packages will most likely share the same name.

### 1. Install Elixir

To install Elixir follow the installation instructions at: http://elixir-lang.org/install.html

The required minimum version for the project is 1.3.

### 2. Install PostgreSQL

To install PostgreSQL other than the ways provided below see: https://wiki.postgresql.org/wiki/Detailed_installation_guides

#### Debian/Ubuntu Linux

```bash
sudo apt-get install postgresql
```

#### Mac OS X (Homebrew)

```bash
brew install postgresql
```


### 3. Install PostGIS

To install the PostGIS extension other than the ways provided below see: http://postgis.net/install/

#### Debian/Ubuntu Linux

```bash
sudo apt-get install postgis
```

#### Mac OS X (Homebrew)

```bash
brew install postgis
```

Setup
-----

### 1. Setup PostgreSQL

#### Debian/Ubuntu Linux

Change the postgres user's password to `postgres`.

```bash
sudo -i -u postgres
psql
ALTER ROLE postgres WITH PASSWORD 'postgres';
```

#### Mac OS X

Create the postgres user, and setup db.

```bash
createuser -s postgres -P # when prompted for password, enter: postgres
```

Note: Whenever running the project you will need to make sure the db instance is running. To do this you will need to run the following:

```bash
postgres -D /usr/local/var/postgres
```

### 2. Setup Project

Retrieve the current dependencies and setup the bonbon_dev database.

```bash
cd bonbon
mix deps.get
mix ecto.setup
```

### 3. Run tests

Check to make sure all tests succeed. If any failed, please notify us.

```bash
mix test
```

### 4. Create docs

To create the project documentation simply run. And then reference the `/docs` folder for the generated documentation.

```bash
mix docs
```
