tmp_file_service_war = File.join('/tmp/', 'file-service.war')

remote_file tmp_file_service_war do
  source "http://jenkins.rogue.lmnsolutions.com/job/file-service/lastSuccessfulBuild/artifact/target/file-service.war"
  action :create
end

execute "deploy_file_service_war" do
  command "mv #{tmp_file_service_war} #{node['tomcat']['webapp_dir']}"
  action :run
  notifies :create, "directory[file_service_store]", :immediately
  notifies :restart, resources(:service => "tomcat")
end

directory "file_service_store" do
  path ::File.join(node['rogue']['geoserver']['data_dir'], 'file-service-store')
  owner node["tomcat"]["user"]
  recursive true
  mode 00755
  action :nothing
end