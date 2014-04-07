include_recipe 'rogue::tomcat_overrides'
include_recipe 'tomcat::default'

group "roguecat" do
  action :modify
  append true
  members node["tomcat"]["user"]
end

directory node['tomcat']['home'] do
  group node["tomcat"]["group"]
  owner node["tomcat"]["user"]
end


# Overwrite the default server.xml
template "tomcat_config" do
  path "#{node["tomcat"]["config_dir"]}/server.xml"
  source "server.xml.erb"
  owner "tomcat7"
  group "tomcat7"
  mode "0644"
  action :create
  notifies :restart, "service[tomcat]", :immediately
end



