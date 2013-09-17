
default['rogue']['web_server'] = 'nginx'

default['rogue']['geonode']['branch'] = 'master'
default['rogue']['geonode']['location'] = '/var/lib/geonode/'
default['rogue']['geonode']['url'] = 'git+https://github.com/GeoNode/geonode.git@' + node['rogue']['geonode']['branch'] + '#egg=geonode'
default['rogue']['interpreter'] = ::File.join(node['rogue']['geonode']['location'], 'bin/python')

default['rogue']['rogue_geonode']['branch'] = 'master'
default['rogue']['rogue_geonode']['location'] = File.join(node['rogue']['geonode']['location'], 'rogue_geonode')
default['rogue']['rogue_geonode']['url'] = 'https://github.com/ROGUE-JCTD/rogue_geonode.git'

default['rogue']['rogue_geonode']['settings']['SITEURL'] = "http://localhost:8000/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] = "http://localhost:8080/geoserver"

default['rogue']['rogue_geonode']['settings']['DATABASES'] = {:default=>{:NAME=>'geonode', :USER=>'geonode', :PASSWORD=>'geonode', :HOST=>'', :PORT=>'5432'}}