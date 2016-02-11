if node.update_hostfile
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
end
