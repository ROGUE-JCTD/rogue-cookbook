database_password = node['rogue']['geonode']['default_database_password']
geoserver_password_hash = node['rogue']['geoserver']['password_hash']
geoserver_root_password_hash = node['rogue']['geoserver']['root_user']['password_hash']
geoserver_root_password_digest = node['rogue']['geoserver']['root_user']['password_digest']

unless node.cleartext_passwords
  include_recipe 'chef-vault'

  database_password = chef_vault_item(database_password[:vault], database_password[:item])[database_password[:field]]
  geoserver_password_hash = chef_vault_item(geoserver_password_hash[:vault], geoserver_password_hash[:item])[geoserver_password_hash[:field]]
  geoserver_root_password_hash = chef_vault_item(geoserver_root_password_hash[:vault], geoserver_root_password_hash[:item])[geoserver_root_password_hash[:field]]
  geoserver_root_password_digest = chef_vault_item(geoserver_root_password_digest[:vault], geoserver_root_password_digest[:item])[geoserver_root_password_digest[:field]]
end

execute "install_geoserver" do
  command "mvn clean install -DskipTests"
  cwd "#{node['rogue']['rogue_geonode']['location']}/geoserver_ext"
  user 'root'
  notifies :stop, "service[#{node.tomcat.service}]", :immediately
  only_if { node['rogue']['geoserver']['build_from_source'] }
end

remote_file_location =
  if node['rogue']['geoserver']['build_from_source']
     "file://#{node['rogue']['rogue_geonode']['location']}/geoserver_ext/target/geoserver.war"
  else
    node['rogue']['geoserver']['war']
  end
  
remote_file "#{node.tomcat.webapp_dir}/geoserver.war" do
  source remote_file_location
  mode 0644
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  notifies :restart, "service[#{node.tomcat.service}]", :immediately
  notifies :run, 'ruby_block[wait-for-geoserver]', :immediately
end

ruby_block "wait-for-geoserver" do
  action :nothing
  block do
    attempts = 0
    loop do
      attempts += 1
      sleep 15
      break unless !File.exist?("#{node.tomcat.webapp_dir}/geoserver/data/security/masterpw.info") and retries < 10
    end
  end
end

service node.tomcat.service do
  action :nothing
  end

template "#{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/web.xml" do
  source 'web.xml.erb'
  retry_delay 15
  retries 15
  owner node['tomcat']['user']
  group node['tomcat']['group']
  notifies :restart, "service[#{node.tomcat.service}]"
  variables(
    :url => node.rogue.geoserver.url,
    :data_dir => node.rogue.geoserver.data_dir,
    :enable_gzip => node.rogue.geoserver.gzip
  )
end

template "#{node["tomcat"]["context_dir"]}/geoserver.xml" do
  source "geoserver.xml.erb"
  mode 00644
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  only_if do node['rogue']['geoserver']['use_db_client'] end
  notifies :restart, "service[#{node.tomcat.service}]"
  variables(
    :database_hostname => node['rogue']['networking']['database']['address'],
    :database_username => node['rogue']['rogue_geonode']['settings']['DATABASES']['default']['user'],
    :database_password => database_password
  )
end

template "#{node.rogue.geoserver.data_dir}/security/usergroup/default/users.xml" do
  source "gs_users.xml.erb"
  mode 0644
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  notifies :restart, "service[#{node.tomcat.service}]"
  variables(
    :password_hash => geoserver_password_hash
  )
end

# downloaded from http://ares.boundlessgeo.com/geoserver/2.6.x/community-latest/geoserver-2.6-SNAPSHOT-python-plugin.zip
# saved to https://github.com/ROGUE-JCTD/rogue-cookbook/tree/master/files/default

cookbook_file "geoserver-2.6-SNAPSHOT-python-plugin.zip" do
  path "#{Chef::Config[:file_cache_path]}/geoserver-2.6-SNAPSHOT-python-plugin.zip"
end

bash "install_geoscript_python_plugin" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    unzip -n geoserver-2.6-SNAPSHOT-python-plugin.zip -d #{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/lib/
    chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/lib
  EOH
  notifies :restart, "service[#{node.tomcat.service}]"
  not_if "test -f #{node.tomcat.webapp_dir}/geoserver/WEB-INF/lib/gs-script-core-2.6-SNAPSHOT.jar"
end

cookbook_file "geoserver-2.6-SNAPSHOT-mbtiles-plugin.zip" do
  path "#{Chef::Config[:file_cache_path]}/geoserver-2.6-SNAPSHOT-mbtiles-plugin.zip"
end

bash "install_mbtiles_plugin" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    unzip -n geoserver-2.6-SNAPSHOT-mbtiles-plugin.zip -d #{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/lib/
    chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/lib
  EOH
  notifies :restart, "service[#{node.tomcat.service}]"
  not_if "test -f #{node.tomcat.webapp_dir}/geoserver/WEB-INF/lib/gs-mbtiles-2.6-SNAPSHOT.jar"
end

# java statistics lib used by wps to compute summarizations for attributes
cookbook_file "commons-math3-3.3.jar" do
  path "#{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/lib/commons-math3-3.3.jar"
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 00644
  retry_delay 15
  retries 8
  notifies :restart, "service[#{node.tomcat.service}]"
end

execute "update GeoNodeAuthProvider" do
  command "sed -i 's_<baseUrl.*_<baseUrl>#{node.scheme}#{node.rogue.networking.application.fqdn}/</baseUrl>_' #{node.rogue.geoserver.data_dir}/security/auth/geonodeAuthProvider/config.xml"
  notifies :restart, "service[#{node.tomcat.service}]"
  not_if "egrep 'baseUrl.*#{node.rogue.networking.application.fqdn}' #{node.rogue.geoserver.data_dir}/security/auth/geonodeAuthProvider/config.xml"
end

file "#{node.rogue.geoserver.data_dir}/security/masterpw.digest" do
  content geoserver_root_password_digest
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0644
  notifies :delete, "file[delete-geoserver-keystore]"
end

file "#{node.rogue.geoserver.data_dir}/security/masterpw/default/passwd" do
  content geoserver_root_password_hash
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 0644
  notifies :delete, "file[delete-geoserver-keystore]"
end

file "delete-geoserver-keystore" do
  path "#{node.rogue.geoserver.data_dir}/security/geoserver.jceks"
  action :nothing
  notifies :restart, "service[#{node.tomcat.service}]"
end
