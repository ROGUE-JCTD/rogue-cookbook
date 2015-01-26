include_recipe 'rogue::tomcat_overrides'
include_recipe 'rogue::rabbitmq_overrides'

rogue_geonode node['rogue']['geonode']['location'] do
  action [:update_local_settings, :start]
  only_if {File.exists? node['rogue']['geonode']['location']}
end

geoserver_config = File.join(node['tomcat']['webapp_dir'], 'geoserver/WEB-INF/web.xml')
template "geoserver_config" do
  path geoserver_config
  source 'web.xml.erb'
  retry_delay 15
  retries 15
  owner node['tomcat']['user']
  group node['tomcat']['group']
  action :create
  only_if {File.exists? File.join(node['tomcat']['webapp_dir'], 'geoserver/WEB-INF/web.xml')}
end
