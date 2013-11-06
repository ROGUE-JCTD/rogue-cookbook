git node['rogue']['geogit']['location'] do
  repository node['rogue']['geogit']['url']
  revision node['rogue']['geogit']['branch']
  action :sync
end

execute "install GeoGIT" do
  command "mvn clean install -DskipTests"
  cwd ::File.join(node['rogue']['geogit']['location'], 'src/parent')
  user 'root'
end

file "/etc/profile.d/geogit.sh" do
  content "export GEOGIT_HOME=#{::File.join(node['rogue']['geogit']['location'], 'src/cli-app/target/geogit')} && PATH=$PATH:$GEOGIT_HOME/bin"
  mode 00755
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