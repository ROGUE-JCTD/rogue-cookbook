include_recipe 'rogue::tomcat_overrides'
include_recipe 'tomcat::default'

group "tomcat7" do
  action :modify
  append true
  # users that can write to the geoserver_data folder 
  members ["unison", "rogue", "www-data"]
end

directory node['tomcat']['home'] do
  group node["tomcat"]["group"]
  owner node["tomcat"]["user"]
end


# Overwrite the default server.xml
template "tomcat_config" do
  path "#{node["tomcat"]["config_dir"]}/server.xml"
  source "server.xml.erb"
  owner node['tomcat']['user']
  group node['tomcat']['user']
  mode "0644"
  action :create
  notifies :restart, "service[tomcat]", :immediately
end


template "#{node['tomcat']['config_dir']}/logging.properties" do
  source 'logging.properties.erb'
  owner 'root'
  group 'root'
  mode '0644'
  cookbook 'rogue'
  notifies :restart, 'service[tomcat]'
end
