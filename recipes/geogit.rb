git node['rogue']['geogit']['location'] do
  repository node['rogue']['geogit']['url']
  revision node['rogue']['geogit']['branch']
  action :sync
end

execute "install_GeoGIT" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geogit']['location'], 'src/parent')
  user 'root'
  action :run
  retries 1
end

file "/etc/profile.d/geogit.sh" do
  content "export GEOGIT_HOME=#{::File.join(node['rogue']['geogit']['location'], 'src/cli-app/target/geogit')} && PATH=$PATH:$GEOGIT_HOME/bin"
  mode 00755
  action :create_if_missing
end

file "gitconfig" do
  path ::File.join(node["tomcat"]["home"], '.geogitconfig')
  content <<-EOH
[user]
name = Rogue
email = rogue@lmnsolutions.com
  EOH
 mode 00755
 only_if do node["tomcat"]["home"] end
 action :create_if_missing
end

git node['rogue']['geoeserver-exts']['location'] do
  repository node['rogue']['geoeserver-exts']['url']
  revision node['rogue']['geoeserver-exts']['branch']
  action :sync
end

execute "build the geoserver_ext" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geoeserver-exts']['location'], 'geogit')
  user 'root'
  action :run
end