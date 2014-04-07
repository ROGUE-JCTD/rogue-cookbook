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

geogit_home = File.join(node['rogue']['geogit']['location'], 'src/cli-app/target/geogit')

file "/etc/profile.d/geogit.sh" do
  content "export GEOGIT_HOME=#{geogit_home} && PATH=$PATH:$GEOGIT_HOME/bin"
  mode 00755
  action :create_if_missing
end

geogit_home = File.join(node['rogue']['geogit']['location'], 'src/cli-app/target/geogit')
node['rogue']['geogit']['global_configuration'].each do |section, values|
    values.each do |key, value|
      bash "geogit global config #{section}.#{key} #{value}" do
        code "#{File.join(geogit_home, '/bin/geogit')} config --global #{section}.#{key} #{value}"
        user "tomcat7"
      end
    end
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

