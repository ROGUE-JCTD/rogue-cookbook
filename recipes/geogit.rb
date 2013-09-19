
git node['rogue']['geogit']['location'] do
  repository node['rogue']['geogit']['url']
  revision node['rogue']['geogit']['branch']
  action :sync
end

package "maven" do
    action :install
end

execute "install GeoGIT" do
  command "mvn clean install -DskipTests -X"
  cwd ::File.join(node['rogue']['geogit']['location'], 'src/parent')
  user 'root'
end

execute "set GeoGIT environmental variable" do
  command "echo GEOGIT_HOME="   + ::File.join(node['rogue']['geogit']['location'], 'src/cli-app/target/geogit') +" >> /etc/profile  && export PATH=$PATH:GEOGIT_HOME/bin >> /etc/profile"
end

