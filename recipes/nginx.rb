node.default['nginx']['init_style'] = "init"
node.default['nginx']['install_method'] = 'source'
node.default['nginx']['source']['version'] = '1.4.1'
node.default['nginx']['source']['url'] = "http://nginx.org/download/nginx-#{node['nginx']['source']['version']}.tar.gz"
node.default['nginx']['source']['prefix']                  = "/opt/nginx-#{node['nginx']['source']['version']}"
node.default['nginx']['source']['conf_path']               = "#{node['nginx']['dir']}/nginx.conf"
node.default['nginx']['source']['sbin_path']               = "#{node['nginx']['source']['prefix']}/sbin/nginx"
node.default['nginx']['source']['default_configure_flags'] = [
  "--prefix=#{node['nginx']['source']['prefix']}",
  "--conf-path=#{node['nginx']['dir']}/nginx.conf",
  "--sbin-path=#{node['nginx']['source']['sbin_path']}"
]

# Set sendfile to off when in development mode.
# http://smotko.si/nginx-static-file-problem/
if node['rogue']['debug']
  node.set['nginx']['sendfile'] = 'off'
end

include_recipe 'nginx::default'
