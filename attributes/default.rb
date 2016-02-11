default['ssl'] = false
default['cleartext_passwords'] = true
default['update_hostfile'] = false
default['create_self_signed_cert'] = false
default['scheme'] = node['ssl'] ? 'https://' : 'http://'

node.set['build-essential']['compile_time'] = true
default['java']['keystore'] = '/usr/lib/jvm/default-java/jre/lib/security/cacerts'
default['java']['keystore_password'] = 'changeit'

default['rogue']['debug'] = true

# default['rogue']['ip'] = 
  # if node.fetch('vagrant', false)
    # node['network']['interfaces']['eth1']['addresses'].detect{|k,v| v[:family] == "inet" }.first
  # else
    # node['ipaddress']
  # end

default['rogue']['ip'] = node['network']['interfaces']['eth1']['addresses'].detect{|k,v| v[:family] == "inet" }.first
default['rogue']['geonode']['admin_user'] = 'admin'

if node.cleartext_passwords
  default['rogue']['postgresql']['password'] = "rogue"
  default['rogue']['geoserver']['password_hash'] = "crypt1:Z22ZwbZyJpL3kt3rZrM3PmY38jsMFYdx"
  default['rogue']['geoserver']['root_user']['password'] = "M(cqp{V1"
  default['rogue']['geoserver']['root_user']['password_hash'] = "3Zjy2QR4bEl30tvwy1GAB7LtA1epMyLg"
  default['rogue']['geoserver']['root_user']['password_digest'] = "digest1:Fu1u5BV1etI1vCxYbIUgWwr1ZtiNYld6hiazyVSPu8nCxTtvNiUO9CkH+m/eu4C8"
  default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD'] = "geoserver"
  default['rogue']['geonode']['default_database_password'] = 'geonode'
  default['rogue']['geonode']['geonode_imports_database_password'] = 'geonode'
  default['rogue']['geonode']['admin_password'] = 'admin'
  default['rogue']['geonode']['admin_password_hash'] = 'sha1$a1ddf$1e14be2baa49df74672c93fa283ba549f56254b7'
  default['rabbitmq']['rogue_password'] = 'geoshape'
else
  # Default chef vault structure for all credentials
  default['rogue']['postgresql']['password'] = {:vault => 'geonode', :item => 'postgresql', :field => 'password'}
  default['rogue']['geoserver']['password_hash'] = {:vault => 'geonode', :item => 'geoserver', :field => 'password_hash'}
  default['rogue']['geoserver']['root_user']['password'] = {:vault => 'geonode', :item => 'geoserver', :field => 'root_user_password'}
  default['rogue']['geoserver']['root_user']['password_hash'] = {:vault => 'geonode', :item => 'geoserver', :field => 'root_user_password_hash'}
  default['rogue']['geoserver']['root_user']['password_digest'] = {:vault => 'geonode', :item => 'geoserver', :field => 'root_user_password_digest'}
  default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD'] = {:vault => 'geonode', :item => 'geoserver', :field => 'password'}
  default['rogue']['geonode']['default_database_password'] = {:vault => 'geonode', :item => 'default_db', :field => 'password'}
  default['rogue']['geonode']['geonode_imports_database_password'] = {:vault => 'geonode', :item => 'geonode_imports_db', :field => 'password'}
  default['rogue']['geonode']['admin_password'] = {:vault => 'geonode', :item => 'geonode', :field => 'password'}
  default['rogue']['geonode']['admin_password_hash'] = {:vault => 'geonode', :item => 'geonode', :field => 'password_hash'}
  default['rabbitmq']['rogue_password'] = {:vault => 'geonode', :item => 'rabbitmq', :field => 'password'}
end

default['rogue']['user']['username'] = 'rogue'
default['rogue']['unison']['username'] = 'unison'

default['rogue']['postgresql']['user'] = 'postgres'
default['rogue']['postgresql']['port'] = 5432

default['rogue']['ssh']['public_key'] = ''
default['rogue']['ssh']['public_key_remote_file'] = '/root/.ssh/id_rsa.pub'
default['rogue']['install_docs'] = true
default['rogue']['logging']['location'] = '/var/log/rogue'
default['rogue']['setup_db'] = true
default['rogue']['aws_rds'] = false
default['rogue']['networking']['application']['hostname'] = 'rogue-geoserver'
default['rogue']['networking']['application']['address'] = node['rogue']['ip']
default['rogue']['networking']['application']['fqdn'] = node['rogue']['ip']
default['rogue']['networking']['application']['gateway'] = nil
default['rogue']['networking']['application']['netmask'] = nil

default['rogue']['networking']['database']['hostname'] = 'rogue-database'
default['rogue']['networking']['database']['address'] = '127.0.0.1'
default['rogue']['networking']['database']['port'] = 5432
default['rogue']['networking']['database']['user'] = 'geonode'
default['rogue']['networking']['database']['gateway'] = nil
default['rogue']['networking']['database']['netmask'] = nil

default['rogue']['networking']['geonode_imports_database']['hostname'] = 'rogue-database'
default['rogue']['networking']['geonode_imports_database']['address'] = '127.0.0.1'
default['rogue']['networking']['geonode_imports_database']['port'] = 5432
default['rogue']['networking']['geonode_imports_database']['user'] = 'geonode_import'
default['rogue']['networking']['geonode_imports_database']['gateway'] = nil
default['rogue']['networking']['geonode_imports_database']['netmask'] = nil

default['rogue']['geoserver']['build_from_source'] = false
default['rogue']['geoserver']['use_db_client'] = true
default['rogue']['geoserver']['base_url'] = '/geoserver'
default['rogue']['geoserver']['data_dir'] = '/var/lib/geoserver_data'
default['rogue']['geoserver']['gzip'] = false
default['rogue']['geoserver']['jai']['url'] = "http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64-jdk.bin"
default['rogue']['geoserver']['jai_io']['url'] = "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64-jdk.bin"
default['rogue']['geoserver']['url']= "#{node['scheme']}#{node['rogue']['networking']['application']['fqdn']}#{node['rogue']['geoserver']['base_url']}/"

default['rogue']['geoserver_data']['url'] = 'https://github.com/ROGUE-JCTD/geoserver_data.git'
default['rogue']['geoserver_data']['branch'] = 'master'
default['rogue']['geonode']['location'] = '/var/lib/geonode/'
default['rogue']['interpreter'] = "#{node['rogue']['geonode']['location']}/bin/python"
default['rogue']['django_maploom']['auto_upgrade'] = true
default['rogue']['django_maploom']['url'] = "git+https://github.com/ROGUE-JCTD/django-maploom.git#egg=django-maploom"

default['rogue']['rogue_geonode']['python_packages'] = ["uwsgi", "psycopg2"]
default['rogue']['rogue_geonode']['location'] = "#{node['rogue']['geonode']['location']}/rogue_geonode"
default['rogue']['rogue_geonode']['url'] = 'https://github.com/boundlessgeo/rogue_geonode.git'
default['rogue']['rogue_geonode']['fixtures'] = ['sample_admin.json',]
default['rogue']['rogue_geonode']['settings']['ALLOWED_HOSTS'] = [node['rogue']['networking']['application']['address'], 'localhost', node['rogue']['networking']['application']['fqdn']]
default['rogue']['rogue_geonode']['settings']['PROXY_ALLOWED_HOSTS'] = ['*', node['rogue']['networking']['application']['address'], '.lmnsolutions.com', '.openstreetmap.org']
default['rogue']['rogue_geonode']['settings']['REGISTRATION_OPEN'] = false
default['rogue']['rogue_geonode']['settings']['SERVER_EMAIL'] = "ROGUE@#{node['rogue']['networking']['application']['fqdn']}"
default['rogue']['rogue_geonode']['settings']['DEFAULT_FROM_EMAIL'] = "webmaster@#{node['rogue']['networking']['application']['fqdn']}"
default['rogue']['rogue_geonode']['settings']['ADMINS'] = []
default['rogue']['rogue_geonode']['settings']['SITEURL'] = "http://#{node['rogue']['networking']['application']['fqdn']}/"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] = node['rogue']['geoserver']['url']
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PUBLIC_LOCATION'] = node['rogue']['geoserver']['url']
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['DATASTORE'] = ""
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['GEOGIG_DATASTORE_DIR'] = "#{node['rogue']['geoserver']['data_dir']}/geogig"
default['rogue']['rogue_geonode']['settings']['OGC_SERVER']['USER'] = "admin"
default['rogue']['rogue_geonode']['settings']['UPLOADER']['BACKEND'] = 'geonode.importer'
default['rogue']['rogue_geonode']['settings']['STATIC_ROOT'] = '/var/www/rogue'
default['rogue']['rogue_geonode']['settings']['MEDIA_ROOT'] = '/var/www/rogue/media'
default['rogue']['nginx']['locations'] = {}
default['nginx']['client_max_body_size']='150M'

default['rogue']['rogue_geonode']['settings']['DATABASES'] = {
  :default=>{:name=>'geonode', :user=>node['rogue']['networking']['database']['user'], :password=>node.rogue.geonode.default_database_password, :host=>node['rogue']['networking']['database']['address'], :port=>node['rogue']['networking']['database']['port'], :conn_max_age=>60},
  :geonode_imports=>{:name=>'geonode_imports', :user=>node['rogue']['networking']['geonode_imports_database']['user'], :password=>node.rogue.geonode.geonode_imports_database_password, :host=>node['rogue']['networking']['geonode_imports_database']['address'], :port=>node['rogue']['networking']['geonode_imports_database']['port'], :conn_max_age=>60}
}
default['rogue']['geogig']['build_from_source'] = false
default['rogue']['geogig']['branch'] = 'SprintRelease'
default['rogue']['geogig']['url'] = 'https://github.com/locationtech/geogig.git' if node['rogue']['geogig']['build_from_source']

default['rogue']['geogig']['global_configuration'] = {
  "user"=> {"name"=>"rogue",
  "email"=>"rogue@lmnsolutions.com"},
  "bdbje"=> {"object_durability"=>"safe"}
}

default['rogue']['geogig']['location'] = '/var/lib/geogig'

default['rogue']['geoeserver-exts']['branch'] = '2.4.x'
default['rogue']['geoeserver-exts']['location'] = '/var/lib/geoserver-exts'
default['rogue']['geoeserver-exts']['url'] = 'https://github.com/ROGUE-JCTD/geoserver-exts.git'
default['rogue']['tomcat']['log_dir'] = "${catalina.base}/logs"

default['rogue']['rogue_geonode']['settings']['CLASSIFICATION_BANNER_ENABLED'] = false
default['rogue']['rogue_geonode']['settings']['CLASSIFICATION_TEXT_COLOR'] = nil
default['rogue']['rogue_geonode']['settings']['CLASSIFICATION_BACKGROUND_COLOR'] = nil
default['rogue']['rogue_geonode']['settings']['CLASSIFICATION_TEXT'] = nil
default['rogue']['rogue_geonode']['settings']['CLASSIFICATION_LINK'] = nil
default['rogue']['rogue_geonode']['settings']['SLACK_ENABLED'] = false
default['rogue']['rogue_geonode']['settings']['SLACK_WEBHOOK_URL'] = nil
default['rogue']['rogue_geonode']['settings']['CORS_ENABLED'] = false

default['rogue']['stig']['url'] = 'https://github.com/ROGUE-JCTD/stig.git'
default['rogue']['stig']['branch'] = 'release-1.0'

default['rogue']['rogue-scripts']['branch'] = 'release-1.0'
default['rogue']['rogue-scripts']['location'] = '/opt/rogue-scripts'
default['rogue']['rogue-scripts']['url'] = 'https://github.com/ROGUE-JCTD/rogue-scripts.git'

######################################################################################
# Note: this ['rogue_geonode']['branch'] version needs to get bumped up when making a new geoshape release. 
#       It should be the release tag on the rogue_geonode repo
######################################################################################
default['rogue']['rogue_geonode']['branch'] =  'master' #release-1.5
default['rogue']['geoserver_data']['branch'] = 'release-1.2' #master
default['rogue']['django_maploom']['auto_upgrade'] = false
default['rogue']['geoserver']['war'] = "https://s3.amazonaws.com/boundlessps-public/geoshape/src/geoserver/2.8/geoserver.war"
default['rogue']['geogig']['url'] = 'https://s3.amazonaws.com/boundlessps-public/geoshape/src/geogig-cli-app-1.0.zip'

default['rabbitmq']['rogue_user'] = {
  :name => 'geoshape',
  :password => node.rabbitmq.rogue_password,
  :rights =>[{ :vhost => nil, :conf => '.*', :write => '.*', :read => '.*' }]
}

default['cert']['name'] = node['rogue']['networking']['application']['fqdn']
default['cert']['key_name'] = node['rogue']['networking']['application']['fqdn']
default['cert']['certificate'] = "/etc/ssl/certs/#{node['cert']['name']}.crt"
default['cert']['key'] = "/etc/ssl/private/#{node['cert']['key_name']}.key"
default['cert']['org'] = 'Org'
default['cert']['org_unit'] = 'Org unit'
default['cert']['country'] = 'US'
default['certs'] = []
