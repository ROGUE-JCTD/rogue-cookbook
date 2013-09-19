ROGUE Cookbook
===============
A stand-alone chef cookbook for the ROGUE JCTD project.

Requirements
------------
Chef community cookbook requirements.

- apt
- git
- java
- tomcat
- nginx

Attributes
----------
#### rogue::default

- `node['rogue']['interpreter']` = The path to the ROGUE python interpreter.
- `node['rogue']['geonode']['branch']` = The branch to use for ROGUE.
- `node['rogue']['geonode']['location']` = The path on the node where Geonode is installed.
- `node['rogue']['geonode']['url']` = The git repository to use for ROGUE.
- `node['rogue']['rogue_geonode']['location']` - The path on the node where ROGUE is installed.
- `node['rogue']['rogue_geonode']['url']` - The git repository to use for ROGUE.
- `node['rogue']['rogue_geonode']['branch']` - The branch to use for ROGUE.
- `node['rogue']['rogue_geonode']['settings']` - ROGUE_GEONODE settings (loaded into local_settings.py).

Usage
-----
#### rogue::default
The default recipe will:

- install ROGUE Geonode from the `master` branch into `/var/lib/geonode/rogue_geonode.`
- install python dependencies
- serve the the application through nginx.

#### rogue::java
The java recipe will:

- install the orcale java jdk

#### rogue::tomcat
The tomcat recipe will:

- install tomcat7

#### rogue::geogit
The geogit recipe will:

- install geogit

Contributing
------------
- Fork the repository on Github
- Create a named feature branch (like `add_component_x`)
- Write your change
- Write tests for your change (if applicable)
- Run the tests, ensuring they all pass
- Submit a Pull Request using Github
