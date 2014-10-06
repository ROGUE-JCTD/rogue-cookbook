require 'serverspec'


describe command('ls /var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/geonode-geoserver-ext*') do
  its(:exit_status) { should eq 0 }
end
