git node['rogue']['geogit']['location'] do
  repository node['rogue']['geogit']['url']
  revision node['rogue']['geogit']['branch']
  action :sync
  only_if { node['rogue']['geogit']['build_from_source'] }
end

execute "install_GeoGIT" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geogit']['location'], 'src/parent')
  user 'root'
  action :run
  retries 1
  only_if { node['rogue']['geogit']['build_from_source'] }
end

remote_file "#{Chef::Config[:file_cache_path]}/geogit-cli-app.zip" do
  source node['rogue']['geogit']['url']
  not_if { node['rogue']['geogit']['build_from_source'] }
  notifies "run", "bash[unzip_geogit]", "immediately"
end

bash "unzip_geogit" do
  code <<-EOF
  unzip #{Chef::Config[:file_cache_path]}/geogit-cli-app.zip -d #{Chef::Config[:file_cache_path]}/geogit-cli-app
  rm -rf #{node['rogue']['geogit']['location']}
  mv #{Chef::Config[:file_cache_path]}/geogit-cli-app/geogit /var/lib
  chmod 755 /var/lib/geogit/ -R
  chown root:roguecat /var/lib/geogit -R
  rm -rf #{Chef::Config[:file_cache_path]}/geogit-cli-app/
  EOF
  user 'root'
  action 'nothing'
end


if node['rogue']['geogit']['build_from_source']
  geogit_home = File.join(node['rogue']['geogit']['location'], 'src/cli-app/target/geogit')
else
  geogit_home = File.join(node['rogue']['geogit']['location'])
end

file "/etc/profile.d/geogit.sh" do
  content "export GEOGIT_HOME=#{geogit_home} && PATH=$PATH:$GEOGIT_HOME/bin"
  mode 00755
  action :create
end

node['rogue']['geogit']['global_configuration'].each do |section, values|
    values.each do |key, value|
      bash "geogit global config #{section}.#{key} #{value}" do
        code "#{File.join(geogit_home, '/bin/geogit')} config --global #{section}.#{key} #{value}"
        user node['tomcat']['user']
      end
    end
end

git node['rogue']['geoeserver-exts']['location'] do
  repository node['rogue']['geoeserver-exts']['url']
  revision node['rogue']['geoeserver-exts']['branch']
  action :sync
  only_if { node['rogue']['geogit']['build_from_source'] }
end

execute "build the geoserver_ext" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geoeserver-exts']['location'], 'geogit')
  user 'root'
  action :run
  only_if { node['rogue']['geogit']['build_from_source'] }
end

