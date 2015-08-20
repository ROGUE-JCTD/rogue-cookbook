apt_repository "opengeo" do
  uri 'https://apt.boundlessgeo.com/suite/v45/ubuntu'
  distribution 'trusty'
  components ['main']
  key 'https://apt.boundlessgeo.com/gpg.key'
end
execute 'echo "deb https://apt.boundlessgeo.com/suite/v45/ubuntu/ trusty main" > /etc/apt/sources.list.d/opengeo.list'
execute 'apt-get update'
execute 'apt-get install -y postgresql-9.3-postgis-2.1'
