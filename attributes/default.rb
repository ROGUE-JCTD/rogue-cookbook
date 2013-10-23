
default['rogue']['web_server'] = 'nginx'
default['rogue']['debug'] = true

default['rogue']['networking']['application']['hostname'] = 'rogue-geoserver'
default['rogue']['networking']['application']['address'] = nil
default['rogue']['networking']['application']['gateway'] = nil
default['rogue']['networking']['application']['netmask'] = nil

default['rogue']['networking']['database']['hostname'] = 'rogue-database'
default['rogue']['networking']['database']['address'] = nil
default['rogue']['networking']['database']['gateway'] = nil
default['rogue']['networking']['database']['netmask'] = nil

default['rogue']['host_only'] = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }[0]
default['rogue']['settings']['ALLOWED_HOSTS'] = [node['rogue']['host_only'], 'localhost']

default['rogue']['geonode']['branch'] = 'master'
default['rogue']['geonode']['location'] = '/var/lib/geonode/'
default['rogue']['geonode']['url'] = 'git+https://github.com/GeoNode/geonode.git@' + node['rogue']['geonode']['branch'] + '#egg=geonode'
default['rogue']['interpreter'] = ::File.join(node['rogue']['geonode']['location'], 'bin/python')

default['rogue']['rogue_geonode']['branch'] = 'master'
default['rogue']['rogue_geonode']['location'] = File.join(node['rogue']['geonode']['location'], 'rogue_geonode')
default['rogue']['rogue_geonode']['url'] = 'https://github.com/ROGUE-JCTD/rogue_geonode.git'

default['rogue']['rogue_geonode']['settings']['SITEURL'] = "http://localhost:8000/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] = "http://#{node['rogue']['host_only']}/geoserver/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['DATASTORE'] = ""
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['GEOGIT_DATASTORE_DIR'] = "/data/geogit/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['USER'] = "admin"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD'] = "geoserver"
default['rogue']['rogue_geonode']['settings']['UPLOADER']['BACKEND'] = 'geonode.importer'

default['rogue']['rogue_geonode']['settings']['DATABASES'] = {
    :default=>{:name=>'geonode', :user=>'geonode', :password=>'geonode', :host=>'localhost', :port=>'5432'},
    :geonode_imports=>{:name=>'geonode_imports', :user=>'geonode', :password=>'geonode', :host=>'localhost', :port=>'5432'}
    }

default['rogue']['geogit']['branch'] = 'SprintRelease'
default['rogue']['geogit']['location'] = '/var/lib/geogit'
default['rogue']['geogit']['url'] = 'https://github.com/ROGUE-JCTD/GeoGit.git'

default[:postgis][:version] = '2.0.4'
default['postgis']['template_name'] = 'template_postgis'
default['postgis']['locale'] = 'en_US.utf8'