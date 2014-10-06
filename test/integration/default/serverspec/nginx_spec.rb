require 'serverspec'


describe "NGINX Service" do
  it "is running on port 80" do
    expect(port(80)).to be_listening
  end
end

describe file('/etc/nginx/sites-enabled/nginx.conf') do
  it { should contain '/static' }
  it { should contain '/docs' }
  it { should contain '/var/run/geonode.sock' }
end