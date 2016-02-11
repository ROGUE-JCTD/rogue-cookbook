directory "#{node['rogue']['geoserver']['data_dir']}/file-service-store" do
  owner node["tomcat"]["user"]
  recursive true
  mode 0775
end

remote_file "#{node.tomcat.webapp_dir}/file-service.war" do
  source "http://files.geoshape.org/file-service.war"
  mode 0644
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  notifies :restart, "service[#{node.tomcat.service}]", :immediately
  notifies :run, 'ruby_block[wait-for-file-service-store]', :immediately
end

ruby_block "wait-for-file-service-store" do
  action :nothing
  block do
    attempts = 0
    loop do
      attempts += 1
      sleep 15
      break unless !File.exist?("#{node.tomcat.webapp_dir}/file-service/WEB-INF/web.xml") and retries < 10
    end
  end
end
