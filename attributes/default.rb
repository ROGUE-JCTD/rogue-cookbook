
default['rogue']['web_server'] = 'nginx'
default['rogue']['debug'] = true

default['rogue']['networking']['application']['hostname'] = 'rogue-geoserver'
default['rogue']['networking']['application']['address'] = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }[0]
default['rogue']['networking']['application']['gateway'] = nil
default['rogue']['networking']['application']['netmask'] = nil

default['rogue']['networking']['database']['hostname'] = 'rogue-database'
default['rogue']['networking']['database']['address'] = '127.0.0.1'
default['rogue']['networking']['database']['gateway'] = nil
default['rogue']['networking']['database']['netmask'] = nil


default['rogue']['settings']['ALLOWED_HOSTS'] = [node['rogue']['networking']['application']['address'], 'localhost']

default['rogue']['geonode']['branch'] = 'master'
default['rogue']['geonode']['location'] = '/var/lib/geonode/'
default['rogue']['geonode']['url'] = 'git+https://github.com/GeoNode/geonode.git@' + node['rogue']['geonode']['branch'] + '#egg=geonode'
default['rogue']['interpreter'] = ::File.join(node['rogue']['geonode']['location'], 'bin/python')

default['rogue']['rogue_geonode']['branch'] = 'master'
default['rogue']['rogue_geonode']['location'] = File.join(node['rogue']['geonode']['location'], 'rogue_geonode')
default['rogue']['rogue_geonode']['url'] = 'https://github.com/ROGUE-JCTD/rogue_geonode.git'

default['rogue']['rogue_geonode']['settings']['SITEURL'] = "http://#{node['rogue']['networking']['application']['address']}:8000/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] = "http://#{node['rogue']['networking']['application']['address']}/geoserver/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['DATASTORE'] = ""
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['GEOGIT_DATASTORE_DIR'] = "/data/geogit/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['USER'] = "admin"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD'] = "geoserver"
default['rogue']['rogue_geonode']['settings']['UPLOADER']['BACKEND'] = 'geonode.importer'

default['rogue']['rogue_geonode']['settings']['DATABASES'] = {
    :default=>{:name=>'geonode', :user=>'geonode', :password=>'geonode', :host=>'rogue-database', :port=>'5432'},
    :geonode_imports=>{:name=>'geonode_imports', :user=>'geonode', :password=>'geonode', :host=>'rogue-database', :port=>'5432'}
    }

default['rogue']['geogit']['branch'] = 'SprintRelease'
default['rogue']['geogit']['location'] = '/var/lib/geogit'
default['rogue']['geogit']['url'] = 'https://github.com/ROGUE-JCTD/GeoGit.git'

default[:postgis][:version] = '2.0.4'
default['postgis']['template_name'] = 'template_postgis'
default['postgis']['locale'] = 'en_US.utf8'

default['rogue']['geoserver']['base_url'] = '/geoserver'
default['rogue']['geoserver']['data_dir'] = '/var/lib/geoserver_data'
default['rogue']['geoserver']['geowebcache']['url'] = "http://sourceforge.net/projects/geowebcache/files/geowebcache/1.4.0/geowebcache-1.4.0-war.zip"
default['rogue']['geoserver']['jai']['url'] = "http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64-jdk.bin"
default['rogue']['geoserver']['jai_io']['url'] = "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64-jdk.bin"