require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe file('/var/lib/geonode/rogue_geonode') do
  it { should be_directory }
end

describe file('/var/lib/geonode/rogue_geonode/docs/build/html/index.html') do
  it { should be_file }
  it { should be_readable.by_user('www-data') }
end

describe file('/var/run/geonode.sock') do
  it { should be_socket }
end