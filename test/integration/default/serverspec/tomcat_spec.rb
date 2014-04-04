require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe user('tomcat7') do
  it { should exist }
  it { should belong_to_group 'roguecat' }
end

describe service('tomcat7') do
  it { should be_running }

  it "is running on port 8080" do
    expect(port(8080)).to be_listening
  end
end

describe file('/etc/tomcat7/server.xml') do
  it { should be_mode 644 }
end