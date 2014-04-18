default['rogue']['debug'] = true
default['rogue']['iface'] = 'eth0'

if node.fetch('vagrant', false)
    default['rogue']['iface'] = 'eth1'
end

default['rogue']['user'] = {:username=>'rogue',
                            :password=>'$1$oqU7lFMn$xYYGAjusAQ59R.NBEAwH7.'
                            }

default['unison']['user'] = {:username=>'unison',
                            :password=>'$1$oqU7lFMn$xYYGAjusAQ59R.NBEAwH7.'
                            }

default['rogue']['postgresql']['user'] = 'postgres'
default['rogue']['postgresql']['password'] = node.fetch('postgresql',{}).fetch('password', {}).fetch('postgres', 'rogue')
default['rogue']['postgresql']['port'] = node.fetch('postgresql',{}).fetch('config', {}).fetch('port', '5432')


default['rogue']['ssh']['public_key'] = ''
default['rogue']['ssh']['public_key_remote_file'] = '/root/.ssh/id_rsa.pub'
default['rogue']['install_docs'] = true
default['rogue']['logging']['location'] = '/var/log/rogue'
default['rogue']['ip'] = node['network']['interfaces'][node['rogue']['iface']]['addresses'].detect{|k,v| v['family'] == "inet" }[0]
default['rogue']['setup_db'] = true
default['rogue']['networking']['application']['hostname'] = 'rogue-geoserver'
default['rogue']['networking']['application']['address'] = node['rogue']['ip']
default['rogue']['networking']['application']['fqdn'] = node['rogue']['ip']
default['rogue']['networking']['application']['gateway'] = nil
default['rogue']['networking']['application']['netmask'] = nil

default['rogue']['networking']['database']['hostname'] = 'rogue-database'
default['rogue']['networking']['database']['address'] = '127.0.0.1'
default['rogue']['networking']['database']['gateway'] = nil
default['rogue']['networking']['database']['netmask'] = nil

default['rogue']['geoserver']['build_from_source'] = false
default['rogue']['geoserver']['use_db_client'] = true
default['rogue']['geoserver']['base_url'] = '/geoserver'
default['rogue']['geoserver']['data_dir'] = '/var/lib/geoserver_data'
default['rogue']['geoserver']['geowebcache']['url'] = "http://sourceforge.net/projects/geowebcache/files/geowebcache/1.4.0/geowebcache-1.4.0-war.zip"
default['rogue']['geoserver']['jai']['url'] = "http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64-jdk.bin"
default['rogue']['geoserver']['jai_io']['url'] = "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64-jdk.bin"
default['rogue']['geoserver']['url']= "http://#{node['rogue']['networking']['application']['fqdn']}#{node['rogue']['geoserver']['base_url']}/"
default['rogue']['geoserver']['war'] = "http://jenkins.rogue.lmnsolutions.com/job/geoserver/lastSuccessfulBuild/artifact/geoserver_ext/target/geoserver.war"

default['rogue']['geoserver_data']['url'] = 'https://github.com/ROGUE-JCTD/geoserver_data.git'
default['rogue']['geoserver_data']['branch'] = 'master'

default['rogue']['geonode']['location'] = '/var/lib/geonode/'
default['rogue']['interpreter'] = ::File.join(node['rogue']['geonode']['location'], 'bin/python')

default['rogue']['django_maploom']['url'] = "git+https://github.com/ROGUE-JCTD/django-maploom.git#egg=django-maploom"
default['rogue']['geonode']['location'] = '/var/lib/geonode/'
default['rogue']['rogue_geonode']['branch'] = 'master'
default['rogue']['rogue_geonode']['location'] = File.join(node['rogue']['geonode']['location'], 'rogue_geonode')
default['rogue']['rogue_geonode']['url'] = 'https://github.com/ROGUE-JCTD/rogue_geonode.git'
default['rogue']['rogue_geonode']['fixtures'] = ['sample_admin.json',]
default['rogue']['rogue_geonode']['settings']['ALLOWED_HOSTS'] = [node['rogue']['networking']['application']['address'], 'localhost', node['rogue']['networking']['application']['fqdn']]
default['rogue']['rogue_geonode']['settings']['PROXY_ALLOWED_HOSTS'] = ['*', node['rogue']['networking']['application']['address'], '.lmnsolutions.com', '.openstreetmap.org']
default['rogue']['rogue_geonode']['settings']['REGISTATION_OPEN'] = false
default['rogue']['rogue_geonode']['settings']['SERVER_EMAIL'] = "ROGUE@#{node['rogue']['networking']['application']['fqdn']}"
default['rogue']['rogue_geonode']['settings']['ADMINS'] = [['ROGUE', 'ROGUE@lmnsolutions.com'],]
default['rogue']['rogue_geonode']['settings']['SITEURL'] = "http://#{node['rogue']['networking']['application']['fqdn']}/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] = node['rogue']['geoserver']['url']
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['DATASTORE'] = ""
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['GEOGIT_DATASTORE_DIR'] = ::File.join(node['rogue']['geoserver']['data_dir'], 'geogit')
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['USER'] = "admin"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD'] = "geoserver"
default['rogue']['rogue_geonode']['settings']['UPLOADER']['BACKEND'] = 'geonode.importer'
default['rogue']['nginx']['locations'] = {}

default['rogue']['rogue_geonode']['settings']['DATABASES'] = {
    :default=>{:name=>'geonode', :user=>'geonode', :password=>'geonode', :host=>'rogue-database', :port=>'5432'},
    :geonode_imports=>{:name=>'geonode_imports', :user=>'geonode', :password=>'geonode', :host=>'rogue-database', :port=>'5432'}
    }
default['rogue']['geogit']['build_from_source'] = false
default['rogue']['geogit']['branch'] = 'SprintRelease'

if node['rogue']['geogit']['build_from_source']
  default['rogue']['geogit']['url'] = 'https://github.com/ROGUE-JCTD/GeoGit.git'
else
  default['rogue']['geogit']['url'] = 'http://jenkins.rogue.lmnsolutions.com/job/geogit/lastSuccessfulBuild/artifact/src/cli-app/target/geogit-cli-app.zip'
end

default['rogue']['geogit']['global_configuration'] = {"user"=> {"name"=>"rogue",
                                                                "email"=>"rogue@lmnsolutions.com"},
                                                      "bdbje"=> {"object_durability"=>"safe"}
                                                      }
default['rogue']['geogit']['location'] = '/var/lib/geogit'


default['rogue']['geoeserver-exts']['branch'] = '2.4.x'
default['rogue']['geoeserver-exts']['location'] = '/var/lib/geoserver-exts'
default['rogue']['geoeserver-exts']['url'] = 'https://github.com/ROGUE-JCTD/geoserver-exts.git'
default['rogue']['tomcat']['log_dir'] = "${catalina.base}/logs"
