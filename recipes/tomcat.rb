include_recipe 'rogue::tomcat_overrides'
include_recipe 'tomcat::default'

group "roguecat" do
  action :modify
  append true
  members node["tomcat"]["user"]
end

# Overwrite the default server.xml
template "tomcat_config" do
  path "#{node["tomcat"]["config_dir"]}/server.xml"
  source "server.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[tomcat]", :immediately
end



