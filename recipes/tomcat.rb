include_recipe 'tomcat'

group "tomcat7" do
  action :modify
  append true
  # users that can write to the geoserver_data folder 
  members ["unison", "rogue", node.nginx.user]
end
