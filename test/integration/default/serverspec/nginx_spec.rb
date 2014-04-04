require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe "NGINX Service" do
  it "is running on port 80" do
    expect(port(80)).to be_listening
  end
end