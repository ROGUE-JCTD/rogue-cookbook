rogue_geonode "/var/lib/geonode" do
 action :install
end

rogue_geonode "/var/lib/geonode" do
 action :syncdb
end
