execute "install_geoserver" do
  command "mvn clean install -DskipTests"
  cwd File.join(node['rogue']['rogue_geonode']['location'], 'geoserver_ext')
  user 'root'
  notifies :stop, "service[tomcat]", :immediately
  only_if { node['rogue']['geoserver']['build_from_source'] }
end

if node['rogue']['geoserver']['build_from_source']
  remote_file_location = "file://#{::File.join(node['rogue']['rogue_geonode']['location'], 'geoserver_ext/target/geoserver.war')}"
else
  remote_file_location = node['rogue']['geoserver']['war']
end

war 'geoserver.war' do
  remote_file_location remote_file_location
  action :deploy
end

service node['tomcat']['user'] do
  action :stop
end

cookbook_file "geonode-geoserver-ext-2.4-SNAPSHOT.jar" do
  path File.join(node['tomcat']['webapp_dir'], 'geoserver/WEB-INF/lib/geonode-geoserver-ext-2.4-SNAPSHOT.jar')
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 00644
  retry_delay 15
  retries 8
  action :create
end

template "geoserver_config" do
  path File.join(node['tomcat']['webapp_dir'], 'geoserver/WEB-INF/web.xml')
  source 'web.xml.erb'
  retry_delay 15
  retries 15
  owner node['tomcat']['user']
  group node['tomcat']['group']
  action :create
end

template "geoserver_db_client_settings" do
  path File.join(node["tomcat"]["context_dir"], 'geoserver.xml')
  source "geoserver.xml.erb"
  mode 00644
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  only_if do node['rogue']['geoserver']['use_db_client'] end
  notifies :restart, "service[tomcat]", :immediately
end

#### Install JAI ####
jai_file = File.join(node['java']['java_home'], 'jai-1_1_3-lib-linux-amd64-jdk.bin')
jai_io_file = File.join(node['java']['java_home'], 'jai_imageio-1_1-lib-linux-amd64-jdk.bin')

remote_file  jai_file do
  source node['rogue']['geoserver']['jai']['url']
  mode 00755
end

remote_file jai_io_file do
  source node['rogue']['geoserver']['jai_io']['url']
  mode 00755
end

execute "fix jai" do
  cwd node['java']['java_home']
  command "sed s/+215/-n+215/ jai_imageio-1_1-lib-linux-amd64-jdk.bin > jai_imageio-1_1-lib-linux-amd64-jdk-fixed.bin"
end

# TODO Need to auto accept the JAI terms.
#execute "install_jai" do
# cwd node['java']['java_home']
# command "bash yes | ./jai-1_1_3-lib-linux-amd64-jdk.bin"
# action :run
#end

# TODO Need to auto accept the JAI IO terms.
#execute "install_jai_io" do
# cwd node['java']['java_home']
# command "bash yes | ./jai_imageio-1_1-lib-linux-amd64-jdk-fixed.bin"
# action :run
#end

service 'tomcat' do
  action :start
end

