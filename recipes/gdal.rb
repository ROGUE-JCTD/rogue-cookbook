# apt_repository "opengeo" do
  # uri 'https://apt.boundlessgeo.com/suite/latest/ubuntu'
  # distribution 'trusty'
  # components ['main']
  # key 'https://apt.boundlessgeo.com/gpg.key'
# end

# package "libgdal-opengeo"

%w{gdal-bin python-gdal}.each{ |pkg|
  package pkg
}
