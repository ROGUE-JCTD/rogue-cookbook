require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe command('ls /var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/geonode-geoserver-ext*') do
  it { should return_exit_status 0 }
end
