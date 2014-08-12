apt_repository "opengeo" do
  uri 'http://apt.opengeo.org/suite/v4/ubuntu/'
  distribution 'lucid'
  components ['main']
  key 'http://apt.opengeo.org/gpg.key'
end

apt_package 'libgdal'

# Install dependencies
pkgs = "libgdal-dev libproj-dev libxml2-dev libgeos-dev".split
pkgs.each { |pkg| package pkg }