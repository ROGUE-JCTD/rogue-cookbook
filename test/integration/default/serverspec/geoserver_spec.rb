require 'serverspec'


describe command('ls /var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/geonode-geoserver-ext*') do
  its(:exit_status) { should eq 0 }
end

describe file('/var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/geoscript-py-1.4-SNAPSHOT.jar') do
  it {should be_file }
  it { should be_owned_by 'tomcat7' }
  it { should be_grouped_into 'tomcat7' }
end

describe file('/var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/commons-math3-3.3.jar') do
  it {should be_file }
  it { should be_owned_by 'tomcat7' }
  it { should be_grouped_into 'tomcat7' }
end