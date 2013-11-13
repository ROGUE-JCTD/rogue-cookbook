execute "install_geoserver" do
  command "mvn clean install -DskipTests"
  cwd File.join(node['rogue']['rogue_geonode']['location'], 'geoserver_ext')
  user 'root'
  notifies :run, "execute[copy_geoserver_war]", :immediately
end

execute "copy_geoserver_war" do
  command "mv #{::File.join(node['rogue']['rogue_geonode']['location'], 'geoserver_ext/target/geoserver.war')} #{node['tomcat']['webapp_dir']}"
  action :nothing
  notifies :restart, resources(:service => "tomcat"), :immediate
end

geoserver_data_dir = File.join(node['tomcat']['webapp_dir'],'geoserver', 'data')

template File.join(node['tomcat']['webapp_dir'], 'geoserver', 'WEB-INF', 'web.xml') do
  source 'web.xml.erb'
  retry_delay 15
  retries 6
  owner node['tomcat']['user']
  group node['tomcat']['group']
  notifies :restart, resources(:service => "tomcat"), :immediate
end

# move the geoserver data dir to correct location
execute "copy geoserver data dir" do
 command "mv #{geoserver_data_dir} #{node['rogue']['geoserver']['data_dir']}"
 action :run
 only_if  do !geoserver_data_dir.eql? node['rogue']['geoserver']['data_dir'] and File.exists? geoserver_data_dir and !File.exists? node['rogue']['geoserver']['data_dir'] end
end

#### Install JAI ####
jai_file = File.join(node['java']['java_home'], 'jai-1_1_3-lib-linux-amd64-jdk.bin')
jai_io_file = File.join(node['java']['java_home'], 'jai_imageio-1_1-lib-linux-amd64-jdk.bin')

remote_file  jai_file do
  source node['rogue']['geoserver']['jai']['url']
  mode 755
end

remote_file jai_io_file do
  source node['rogue']['geoserver']['jai_io']['url']
  mode 755
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

