geonode_pkgs = %w{libxml2-dev libxslt-dev libjpeg-dev zlib1g-dev libpng12-dev python-dev imagemagick}

package "maven" if node['rogue']['geoserver']['build_from_source']

geonode_pkgs.each do |pkg|
  package pkg do
    retries 8
  end
end

include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'python'
include_recipe 'rogue::permissions'
include_recipe 'rogue::java'
include_recipe 'rogue::gdal'
include_recipe 'rogue::tomcat'
include_recipe 'rogue::geogig'
include_recipe 'rogue::networking'
include_recipe 'rogue::unison'
include_recipe 'rogue::stig'
include_recipe 'rogue::roguescripts'
include_recipe 'rogue::rabbitmq'
include_recipe 'rogue::celery'
include_recipe 'rogue::certs'
include_recipe 'rogue::nginx'

source = "/usr/lib/x86_64-linux-gnu/libjpeg.so"
target = "/usr/lib/libjpeg.so"
# This fixes https://github.com/ROGUE-JCTD/rogue_geonode/issues/17
link target do
  to source
  not_if do File.exists?(target) or !File.exists?(source) end
  action :create
end

if node['rogue']['setup_db']
  include_recipe 'rogue::database'
end

%w{/var/www/rogue /var/www/rogue/media}.each{ |dir|
  directory dir
}

database_password = node['rogue']['geonode']['default_database_password']
data_store_password = node['rogue']['geonode']['geonode_imports_database_password']
geoserver_password = node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD']
rabbitmq_password = node['rabbitmq']['rogue_password']
geonode_admin_password_hash = node['rogue']['geonode']['admin_password_hash']


unless node.cleartext_passwords
  include_recipe 'chef-vault'

  database_password = chef_vault_item(database_password[:vault], database_password[:item])[database_password[:field]]
  data_store_password = chef_vault_item(data_store_password[:vault], data_store_password[:item])[data_store_password[:field]]
  geoserver_password = chef_vault_item(geoserver_password[:vault], geoserver_password[:item])[geoserver_password[:field]]
  rabbitmq_password = chef_vault_item(rabbitmq_password[:vault], rabbitmq_password[:item])[rabbitmq_password[:field]]
  geonode_admin_password_hash = chef_vault_item(geonode_admin_password_hash[:vault], geonode_admin_password_hash[:item])[geonode_admin_password_hash[:field]]
end

rogue_geonode node['rogue']['geonode']['location'] do
  action :install
  geoserver_password geoserver_password
  rabbitmq_password rabbitmq_password
  data_store_password data_store_password
  database_password database_password
end

include_recipe 'rogue::geoserver_data'
include_recipe 'rogue::geoserver'
include_recipe 'rogue::fileservice'

template "#{node['nginx']['dir']}/proxy.conf" do
  source 'proxy.conf.erb'
  owner node.nginx.user
  group node.nginx.group
  notifies :reload, "service[nginx]"
  variables(
    :buffer_size => node['nginx']['proxy']['buffer_size'],
    :connect_timeout => node['nginx']['proxy']['connect_timeout'],
    :send_timeout => node['nginx']['proxy']['send_timeout'],
    :read_timeout => node['nginx']['proxy']['read_timeout'],
    :buffers => node['nginx']['proxy']['buffers']
  )
end

template "#{node['nginx']['dir']}/sites-enabled/nginx.conf" do
  source "nginx.conf.erb"
  notifies :reload, "service[nginx]", :immediately
  owner node.nginx.user
  group node.nginx.group
  variables(
    :proxy_conf => "#{node['nginx']['dir']}/proxy.conf",
    :ssl_enabled => node['ssl'],
    :ssl_certificate => node['cert']['certificate'],
    :ssl_certificate_key => node['cert']['key'],
    :ssl_session_cache_timeout => node['nginx']['ssl']['session_cache_timeout'],
    :ssl_session_timeout => node['nginx']['ssl']['session_timeout'],
    :ssl_protocols => node['nginx']['ssl']['protocols'],
    :ssl_ciphers => node['nginx']['ssl']['ciphers'],
    :ssl_ttl => node['nginx']['ssl']['ttl'],
    :geonode_location => node['rogue']['rogue_geonode']['location'],
    :web_root => node['rogue']['rogue_geonode']['settings']['STATIC_ROOT'],
    :media_root => node['rogue']['rogue_geonode']['settings']['MEDIA_ROOT'],
    :geonode_nginx_location => node['rogue']['nginx']['locations'],
    :doc_enabled => node['rogue']['install_docs'],
    :nginx_basedir => node['nginx']['dir'],
    :nginx_body_size => node['nginx']['client_max_body_size']
  )
end

# Create the GeoGig datastore directory
directory node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['GEOGIG_DATASTORE_DIR'] do
  owner node['tomcat']['user']
  recursive true
  mode 00755
  notifies :restart, "service[#{node.tomcat.service}]"
end

rogue_geonode node['rogue']['geonode']['location'] do
  action [:sync_db, :update_site, :create_postgis_datastore]
end

rogue_geonode node['rogue']['geonode']['location'] do
  action :load_data
  geonode_admin_password_hash geonode_admin_password_hash
  not_if "#{node[:rogue][:geonode][:location]}bin/python -c \"from django.contrib.auth.models import User; User.objects.get(id=1)\"", :environment=>{'DJANGO_SETTINGS_MODULE' => 'geoshape.settings'}
end

rogue_geonode node['rogue']['geonode']['location'] do
  action [:update_layers, :start, :build_html_docs]
end

execute "start_celery-worker" do
  command 'supervisorctl start rogue-celery'
  not_if "supervisorctl status rogue-celery | grep RUNNING"
  not_if "service celeryd status | grep running"
end

log "Rogue is now running on #{node['rogue']['networking']['application']['address']}."
