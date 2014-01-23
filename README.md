ROGUE Cookbook
===============
A stand-alone chef cookbook for the ROGUE-JCTD project.  This cookbook can be used to install and configure all of the ROGUE components.

Requirements
------------
Chef community cookbook requirements.

- apt
- database
- git
- hostsfile
- java
- nginx
- ohai
- postgresql
- tomcat

Attributes
----------
#### rogue::default

- `node['rogue']['debug']`= Boolean.  Determines whether applications should be configured in debug mode.
- `node['rogue']['django_maploom']['url']` - The url to use when using pip to download Django-Maploom.
- `node['rogue']['geogit']['branch']` = The geogit branch to during the installation.
- `node['rogue']['geogit']['location']` = The geogit installation location.
- `node['rogue']['geogit']['url']` = The git repository url for geogit.
- `node['rogue']['geoserver']['use_db_client']` = Boolean.  If true, geoserver will use the database client in the geonode-geoserver extension to authenticate users.
- `node['rogue']['geoserver']['url']` = The full url to Geoserver in ROGUE.
- `node['rogue']['geoserver']['base_url']` = Geoserver's URL route in ROGUE.
- `node['rogue']['geoserver']['data_dir']` = The location of the geoserver data directory.
- `node['rogue']['geoserver']['geowebcache']['url']` = The URL used to download GeoWebCache.
- `node['rogue']['geoserver']['jai']['url']` = The URL used to download JAI.
- `node['rogue']['geoserver']['jai_io']['url']` = The URL used to download JAI IO.
- `node['rogue']['interpreter']` = The path to the ROGUE python interpreter.
- `node['rogue']['ip']` = The IP address used to configure ROGUE applications.
- `node['rogue']['iface']` = The network interface used to obtain the ip.  Defaults to eth1 when the vagrant attribute is true, eth0 all other times.
- `node['rogue']['logging']['location']` = The location where ROGUE logs should be stored.
- `node['rogue']['networking']['application']['address']` = The application server's ip address (if static).
- `node['rogue']['networking']['application']['fqdn']` = The FQDN used to configure ROGUE applications.
- `node['rogue']['networking']['application']['gateway']` = The application server's gateway (if applicable).
- `node['rogue']['networking']['application']['hostname']` = The application server's hostname.
- `node['rogue']['networking']['application']['netmask']` = The application server's netmask (if applicable).
- `node['rogue']['networking']['database']['address']` = The database server's address (if static).
- `node['rogue']['networking']['database']['gateway']` = The database server's gateway (if applicable).
- `node['rogue']['networking']['database']['hostname']` = The database server's hostname.
- `node['rogue']['networking']['database']['netmask']` = The database server's netmask (if applicable)
- `node['rogue']['nginx']['locations']` = Key, value pairs used to generate nginx location directives.
- `node['rogue']['rogue_geonode']['location']` - The path on the node where ROGUE is installed.
- `node['rogue']['rogue_geonode']['url']` - The git repository to use for ROGUE.
- `node['rogue']['rogue_geonode']['branch']` - The branch to use for ROGUE.
- `node['rogue']['rogue_geonode']['settings']` - ROGUE_GEONODE settings (loaded into local_settings.py).
- `node['rogue']['settings']['ALLOWED_HOSTS']` = An array of hosts allowed to make requests to GeoNode.
- `node['rogue']['settings']['PROXY_ALLOWED_HOSTS']` = An array of hosts that the GeoNode can forward requests to.
- `node['rogue']['ssh']['public_key']` = A public key used for the rogue user to support file synchronization.
- `node['rogue']['ssh']['public_key_remote_file']` = The location where to store the public key on the guest machine.
- `node['rogue']['iface']` = The network interface used to obtain the ip.  Defaults to eth1 when the vagrant attribute is true, eth0 all other times.

Usage
-----
#### rogue::database
The database recipe will:

- Create the GeoNode database
- Create the GeoNode user
- Create a PostGIS database for imported geospatial data
- Add a function to authorize layers, using GeoNode permissions when users visit Geoserver

#### rogue::default
The default recipe will:

- install ROGUE Geonode from the `master` branch into `/var/lib/geonode/rogue_geonode.`
- install python dependencies
- serve the the application through nginx.

#### rogue::fileservice
The fileservice recipe will:

- Download the fileservice war and deploy it to Tomcat
- Create a file-service-store in the Geoserver data directory, if it does not already exist

#### rogue::geogit
The geogit recipe will:

- install geogit

#### rogue::geoserver
The geoserver recipe will:

- Build Geoserver from the `geoserver_ext` folder in the ROGUE-GEONODE git repository
- Deploy the Geoserver war to Tomcat
- Manually deploy the GeoNode-Geoserver extension .jar file to Geoserver's lib folder
- Download JAI and JAI/IO

#### rogue::geoserver_data
The geoserver_data recipe will:

- Clone a default Geoserver data directory from Github if the Geoserver data directory does not already exist
- Modify the permissions of the Geoserver data directory to work with the unison file synchronization application.

#### rogue::java
The java recipe will:

- Install the Orcale Java JDK

#### rogue::networking
The networking recipe will:

- Add the host names for the application and database server to the hostsfile

#### rogue::nginx
The nginx recipe will:

- Download and install Nginx from source

#### rogue::permissions
The permissions recipe will:

- Create a `rogue` user account
- Create a `roguecat` group for files that Rogue and Tomcat both have permissions on

#### rogue::postgis
The postgis recipe will:

- Download and compile PostGIS and its dependencies
- Create a PostGIS database template

#### rogue::postgresql
The postgresql recipe will:

- Set the default pg_hba.conf
- Set the default postgres password
- Install PostgreSQL Server and call the PostGIS recipe

#### rogue::tomcat
The tomcat recipe will:

- Install tomcat7

#### rogue::unison
The unison recipe will:

- Install Unison, ACL, and Keychain
- Update root's fstab entry to add acl

Contributing
------------
- Fork the repository on Github
- Create a named feature branch (like `add_component_x`)
- Write your change
- Write tests for your change (if applicable)
- Run the tests, ensuring they all pass
- Submit a Pull Request using Github
