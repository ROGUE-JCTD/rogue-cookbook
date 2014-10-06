require 'serverspec'


describe user('tomcat7') do
  it { should exist }
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

describe file('/usr/share/tomcat7') do
  it { should be_directory }
  it { should be_owned_by 'tomcat7' }
  it { should be_grouped_into 'tomcat7' }
end

describe file('/etc/tomcat7/logging.properties') do
  it { should be_file }
  it { should contain '${catalina.base}/logs' }
end