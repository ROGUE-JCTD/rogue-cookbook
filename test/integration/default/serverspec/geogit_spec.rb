require 'serverspec'

describe file('/usr/share/tomcat7/.geogigconfig') do
  it { should contain '[user]' }
  it { should contain 'name = rogue' }
  it { should contain 'email = rogue@lmnsolutions.com'}
  it { should contain '[bdbje]' }
  it { should contain 'object_durability = safe' }
end

describe file('/etc/profile.d/geogig.sh') do
  it { should contain '/var/lib/geogig'}
  it { should be_executable }
end

describe file('/var/lib/geogig/bin/geogig') do
  it { should be_executable }
  it { should be_executable.by_user('rogue') }
  it { should be_executable.by_user('tomcat7') }
  it { should be_grouped_into 'roguecat' }
  it { should be_mode 755}
end

describe command('ls /var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/gs-geogig*') do
  its(:exit_status) { should eq 0 }
end