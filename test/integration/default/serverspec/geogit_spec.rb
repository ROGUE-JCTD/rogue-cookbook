require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe file('/usr/share/tomcat7/.geogitconfig') do
  it { should contain '[user]' }
  it { should contain 'name = rogue' }
  it { should contain 'email = rogue@lmnsolutions.com'}
  it { should contain '[bdbje]' }
  it { should contain 'object_durability = safe' }
end

describe file('/etc/profile.d/geogit.sh') do
  it { should contain '/var/lib/geogit'}
  it { should be_executable }
end