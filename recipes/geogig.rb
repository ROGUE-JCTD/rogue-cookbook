git node['rogue']['geogig']['location'] do
  repository node['rogue']['geogig']['url']
  revision node['rogue']['geogig']['branch']
  action :sync
  only_if { node['rogue']['geogig']['build_from_source'] }
end

execute "install_GeoGig" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geogig']['location'], 'src/parent')
  user 'root'
  action :run
  retries 1
  only_if { node['rogue']['geogig']['build_from_source'] }
end

remote_file "#{Chef::Config[:file_cache_path]}/geogig-cli-app-1.0.zip" do
  source node['rogue']['geogig']['url']
  not_if { node['rogue']['geogig']['build_from_source'] }
  notifies "run", "bash[unzip_geogig]", "immediately"
end

bash "unzip_geogig" do
  code <<-EOF
  unzip #{Chef::Config[:file_cache_path]}/geogig-cli-app-1.0.zip -d #{Chef::Config[:file_cache_path]}/geogig-cli-app
  rm -rf #{node['rogue']['geogig']['location']}
  mv #{Chef::Config[:file_cache_path]}/geogig-cli-app/geogig /var/lib
  chmod 755 /var/lib/geogig/ -R
  chown rogue:rogue /var/lib/geogig -R
  rm -rf #{Chef::Config[:file_cache_path]}/geogig-cli-app/
  EOF
  user 'root'
  action 'nothing'
end


if node['rogue']['geogig']['build_from_source']
  geogig_home = File.join(node['rogue']['geogig']['location'], 'src/cli-app/target/geogig')
else
  geogig_home = File.join(node['rogue']['geogig']['location'])
end

file "/etc/profile.d/geogig.sh" do
  content "export GEOGIG_HOME=#{geogig_home} && PATH=$PATH:$GEOGIG_HOME/bin"
  mode 00755
  action :create
end

node['rogue']['geogig']['global_configuration'].each do |section, values|
    values.each do |key, value|
      bash "geogig global config #{section}.#{key} #{value}" do
        code "#{File.join(geogig_home, '/bin/geogig')} config --global #{section}.#{key} #{value}"
        user node['tomcat']['user']
      end
    end
end

git node['rogue']['geoeserver-exts']['location'] do
  repository node['rogue']['geoeserver-exts']['url']
  revision node['rogue']['geoeserver-exts']['branch']
  action :sync
  only_if { node['rogue']['geogig']['build_from_source'] }
end

execute "build the geoserver_ext" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geoeserver-exts']['location'], 'geogig')
  user 'root'
  action :run
  only_if { node['rogue']['geogig']['build_from_source'] }
end

