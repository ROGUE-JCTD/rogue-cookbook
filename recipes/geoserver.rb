execute "install_geoserver" do
  command "mvn clean install -DskipTests"
  cwd File.join(node['rogue']['rogue_geonode']['location'], 'geoserver_ext')
  user 'root'
  notifies :stop, "service[tomcat]", :immediately
  notifies :run, "execute[remove_old_geoserver_directory]", :immediately
  notifies :run, "execute[copy_geoserver_war]", :immediately
end

execute "remove_old_geoserver_directory" do
  command "rm -rf #{File.join(node['tomcat']['webapp_dir'],'geoserver')}"
  only_if { File.exists? File.join(node['tomcat']['webapp_dir'],'geoserver') }
  action :nothing
end

execute "copy_geoserver_war" do
  command "mv #{::File.join(node['rogue']['rogue_geonode']['location'], 'geoserver_ext/target/geoserver.war')} #{node['tomcat']['webapp_dir']} && chmod 644 /var/lib/tomcat7/webapps/geoserver.war"
  action :nothing
  notifies :restart, "service[tomcat]", :immediately
  notifies :stop, "service[tomcat]", :immediately
  notifies :create, "template[geoserver_config]", :immediately
  notifies :create, "cookbook_file[geonode-geoserver-ext-2.3-SNAPSHOT.jar]", :immediately
  notifies :start, "service[tomcat]", :immediately
end

cookbook_file "geonode-geoserver-ext-2.3-SNAPSHOT.jar" do
  path File.join(node['tomcat']['webapp_dir'], 'geoserver/WEB-INF/lib/geonode-geoserver-ext-2.3-SNAPSHOT.jar')
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode 00644
  retry_delay 15
  retries 8
  action :nothing
end

template "geoserver_config" do
  path File.join(node['tomcat']['webapp_dir'], 'geoserver', 'WEB-INF', 'web.xml')
  source 'web.xml.erb'
  retry_delay 15
  retries 8
  owner node['tomcat']['user']
  group node['tomcat']['group']
  action :nothing
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

geoserver_data_dir = '/opt/geoserver_data'
git geoserver_data_dir do
  repository "https://github.com/ROGUE-JCTD/geoserver_data.git"
  user 'root'
  action :export
  not_if do File.exists? node['rogue']['geoserver']['data_dir'] end
end

dirs = "#{node['rogue']['geoserver']['data_dir']} #{File.join(node['rogue']['geoserver']['data_dir'], 'geogit')} #{File.join(node['rogue']['geoserver']['data_dir'], 'file-service-store')}"

# move the geoserver data dir to correct location
execute "copy geoserver data dir" do
 command <<-EOH
   mv #{geoserver_data_dir} #{node['rogue']['geoserver']['data_dir']}
   chown -R #{node['tomcat']['user']}:roguecat #{dirs}
   chmod -R 775 #{node['rogue']['geoserver']['data_dir']} #{dirs}
 EOH
 action :run
 only_if  do !geoserver_data_dir.eql? node['rogue']['geoserver']['data_dir'] and File.exists? geoserver_data_dir and !File.exists? node['rogue']['geoserver']['data_dir'] end
 notifies :run, "execute[change_perms]"
 user 'root'
end

# TODO This needs to go somewhere else
include_recipe 'rogue::fileservice'

geogit = File.join(node['rogue']['geoserver']['data_dir'], 'geogit')
file_store = File.join(node['rogue']['geoserver']['data_dir'],'file-service-store')

execute "change_perms" do
  command <<-EOH
    chmod g+s #{geogit} #{file_store}
    setfacl -d -m g::rwx #{geogit}
    setfacl -d -m o::rx #{geogit}
    setfacl -d -m g::rwx #{file_store}
    setfacl -d -m o::rx #{file_store}

    find #{geogit} -type d -print0 | xargs -0 chmod 775
    find #{geogit} -type f -print0 | xargs -0 chmod 664

    chown tomcat7:roguecat -R #{geogit}
    find #{geogit} -type d -print0 | xargs -0 setfacl -d -m g::rwx
    find #{geogit} -type d -print0 | xargs -0 setfacl -d -m o::rx
    chown tomcat7:roguecat -R #{file_store}
    chmod 664 #{file_store}/*
  EOH
  user 'root'
  action :nothing
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

