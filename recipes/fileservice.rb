war 'file-service.war' do
  remote_file_location "http://jenkins.rogue.lmnsolutions.com/userContent/file-service.war"
  action :deploy
  notifies :create, "directory[file_service_store]", :immediately
end


directory "file_service_store" do
  path ::File.join(node['rogue']['geoserver']['data_dir'], 'file-service-store')
  owner node["tomcat"]["user"]
  recursive true
  mode 00775
  not_if do File.join(node['rogue']['geoserver']['data_dir'], 'file-service-store') end
  action :nothing
end