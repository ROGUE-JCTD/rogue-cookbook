# Override tomcat community cookbook to default to version 7.

node.default['tomcat']['base_version'] = 7

case node['platform']

when "centos","redhat","fedora", "amazon", "scientific"
  node.default["tomcat"]["home"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["base"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["config_dir"] = "/etc/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["log_dir"] = "/var/log/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["tmp_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}/temp"
  node.default["tomcat"]["work_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}/work"
  node.default["tomcat"]["context_dir"] = "#{node["tomcat"]["config_dir"]}/Catalina/localhost"
  node.default["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}/webapps"
  node.default["tomcat"]["keytool"] = "/usr/lib/jvm/java/bin/keytool"
  node.default["tomcat"]["lib_dir"] = "#{node["tomcat"]["home"]}/lib"
  node.default["tomcat"]["endorsed_dir"] = "#{node["tomcat"]["lib_dir"]}/endorsed"
when "debian","ubuntu"
  node.default["tomcat"]["user"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["group"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["home"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["base"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["config_dir"] = "/etc/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["log_dir"] = "/var/log/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["tmp_dir"] = "/tmp/tomcat#{node["tomcat"]["base_version"]}-tmp"
  node.default["tomcat"]["work_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["context_dir"] = "#{node["tomcat"]["config_dir"]}/Catalina/localhost"
  node.default["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}/webapps"
  node.default["tomcat"]["keytool"] = "/usr/lib/jvm/default-java/bin/keytool"
  node.default["tomcat"]["lib_dir"] = "#{node["tomcat"]["home"]}/lib"
  node.default["tomcat"]["endorsed_dir"] = "#{node["tomcat"]["lib_dir"]}/endorsed"
else
  node.default["tomcat"]["user"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["group"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["home"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["base"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["config_dir"] = "/etc/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["log_dir"] = "/var/log/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["tmp_dir"] = "/tmp/tomcat#{node["tomcat"]["base_version"]}-tmp"
  node.default["tomcat"]["work_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}"
  node.default["tomcat"]["context_dir"] = "#{node["tomcat"]["config_dir"]}/Catalina/localhost"
  node.default["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}/webapps"
  node.default["tomcat"]["keytool"] = "keytool"
  node.default["tomcat"]["lib_dir"] = "#{node["tomcat"]["home"]}/lib"
  node.default["tomcat"]["endorsed_dir"] = "#{node["tomcat"]["lib_dir"]}/endorsed"
end


node.default["tomcat"]["java_options"] = "-Djava.awt.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC"

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



