log "Updating network interfaces."

# configure hostnames
hostsfile_entry '127.0.0.1' do
  hostname node['rogue']['networking']['application']['hostname']
  action :append
end

hostsfile_entry node['rogue']['networking']['database']['address'] do
  hostname node['rogue']['networking']['database']['hostname']
  only_if do node['rogue']['networking']['database']['address'] && node['rogue']['networking']['database']['hostname'] end
  action :append
end

# configure network interfaces
#if node['rogue']['networking']['application']['address']
#    ifconfig node['rogue']['networking']['application']['address'] do
#      device "eth0"
#      mask node['rogue']['networking']['application']['netmask']
#    end
#
#    route node['rogue']['networking']['application']['address'] do
#      device "eth0"
#      gateway node['rogue']['networking']['application']['gateway']
#      netmask node['rogue']['networking']['application']['netmask']
#
#      only_if do node['rogue']['networking']['application']['address'] end
#    end
#end



