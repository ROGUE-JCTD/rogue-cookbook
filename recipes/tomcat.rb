# Override tomcat community cookbook to default to version 7.

node.set['tomcat']['base_version'] = 7

case node['platform']

when "centos","redhat","fedora"
  node.set["tomcat"]["home"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["base"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["config_dir"] = "/etc/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["tmp_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}/temp"
  node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}/work"
  node.set["tomcat"]["context_dir"] = "#{node["tomcat"]["config_dir"]}/Catalina/localhost"
  node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}/webapps"
  node.set["tomcat"]["keytool"] = "/usr/lib/jvm/java/bin/keytool"
  node.set["tomcat"]["lib_dir"] = "#{node["tomcat"]["home"]}/lib"
  node.set["tomcat"]["endorsed_dir"] = "#{node["tomcat"]["lib_dir"]}/endorsed"
when "debian","ubuntu"
  node.set["tomcat"]["user"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["group"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["home"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["base"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["config_dir"] = "/etc/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["tmp_dir"] = "/tmp/tomcat#{node["tomcat"]["base_version"]}-tmp"
  node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["context_dir"] = "#{node["tomcat"]["config_dir"]}/Catalina/localhost"
  node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}/webapps"
  node.set["tomcat"]["keytool"] = "/usr/lib/jvm/default-java/bin/keytool"
  node.set["tomcat"]["lib_dir"] = "#{node["tomcat"]["home"]}/lib"
  node.set["tomcat"]["endorsed_dir"] = "#{node["tomcat"]["lib_dir"]}/endorsed"
else
  node.set["tomcat"]["user"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["group"] = "tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["home"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["base"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["config_dir"] = "/etc/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["tmp_dir"] = "/tmp/tomcat#{node["tomcat"]["base_version"]}-tmp"
  node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{node["tomcat"]["base_version"]}"
  node.set["tomcat"]["context_dir"] = "#{node["tomcat"]["config_dir"]}/Catalina/localhost"
  node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}/webapps"
  node.set["tomcat"]["keytool"] = "keytool"
  node.set["tomcat"]["lib_dir"] = "#{node["tomcat"]["home"]}/lib"
  node.set["tomcat"]["endorsed_dir"] = "#{node["tomcat"]["lib_dir"]}/endorsed"
end

node.set["tomcat"]["java_options"] = "-Djava.awt.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC"

include_recipe 'tomcat::default'

template "#{node["tomcat"]["config_dir"]}/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[tomcat]"
end



