geoserver_data_dir = '/opt/geoserver_data'
git geoserver_data_dir do
  repository "https://github.com/ROGUE-JCTD/geoserver_data.git"
  user 'root'
  action :export
  not_if do File.exists? node['rogue']['geoserver']['data_dir'] end
end

dirs = "#{node['rogue']['geoserver']['data_dir']} #{File.join(node['rogue']['geoserver']['data_dir'], 'geogit')} #{File.join(node['rogue']['geoserver']['data_dir'], 'file-service-store')}"

# move the geoserver data dir to the correct location
execute "copy_geoserver_data_dir" do
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