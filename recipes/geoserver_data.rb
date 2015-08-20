geoserver_data_dir = '/opt/geoserver_data'
git geoserver_data_dir do
  repository node['rogue']['geoserver_data']['url']
  user 'root'
  action :sync
  revision node['rogue']['geoserver_data']['branch']
  not_if do File.exists? node['rogue']['geoserver']['data_dir'] end
end

geogig = File.join(node['rogue']['geoserver']['data_dir'], 'geogig')
file_store = File.join(node['rogue']['geoserver']['data_dir'],'file-service-store')
workspaces = File.join(node['rogue']['geoserver']['data_dir'],'workspaces')


# move the geoserver data dir to the correct location
execute "copy_geoserver_data_dir" do
  command <<-EOH
    cp -R #{geoserver_data_dir} #{node['rogue']['geoserver']['data_dir']}
  EOH
  action :run
  only_if  do !geoserver_data_dir.eql? node['rogue']['geoserver']['data_dir'] and File.exists? geoserver_data_dir and !File.exists? node['rogue']['geoserver']['data_dir'] end
  notifies :create, "directory[#{file_store}]", :immediately
  notifies :run, "execute[change_perms]", :immediately
  user 'root'
end

directory file_store do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  action :create
  not_if { File.exists? file_store }
end

execute "change_perms" do
  command <<-EOH
    # all files/folders under data_dir tomcat7:tomcat7 with 775
    chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['rogue']['geoserver']['data_dir']}
    chmod -R 775 #{node['rogue']['geoserver']['data_dir']}

    # all files/folders created under the specified directories should inherit the group permisions 
    chmod g+s #{geogig}
    chmod g+s #{file_store}
    
    # new folders created under workspaces folder (and any existing folder under workspace) should inherit 
    # the group of this workspaces folder (tomcat7) and that group should have rwx by default. This will 
    # allow gsschema service which is ran as www-data user & group (which is member of the tomcat7 group)
    # to write schema.xsd files to the workspaces folder. 
    find #{workspaces} -type d -print0 | xargs -0 chmod g+s
    find #{workspaces} -type d -print0 | xargs -0 setfacl -d -m g::rwx

    find #{geogig} -type f -print0 | xargs -0 chmod 664
    find #{geogig} -type d -print0 | xargs -0 setfacl -d -m g::rwx
    find #{geogig} -type d -print0 | xargs -0 setfacl -d -m o::rx

    chmod 664 #{file_store}/*
  EOH
  user 'root'
  action :nothing
end
