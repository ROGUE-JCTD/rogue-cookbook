node.set['nginx']['init_style'] = "init"
node.set['nginx']['install_method'] = 'source'
node.set['nginx']['source']['version'] = '1.4.1'
node.set['nginx']['source']['url'] = "http://nginx.org/download/nginx-#{node['nginx']['source']['version']}.tar.gz"
node.set['nginx']['source']['prefix']                  = "/opt/nginx-#{node['nginx']['source']['version']}"
node.set['nginx']['source']['conf_path']               = "#{node['nginx']['dir']}/nginx.conf"
node.set['nginx']['source']['sbin_path']               = "#{node['nginx']['source']['prefix']}/sbin/nginx"
node.set['nginx']['source']['default_configure_flags'] = [
  "--prefix=#{node['nginx']['source']['prefix']}",
  "--conf-path=#{node['nginx']['dir']}/nginx.conf",
  "--sbin-path=#{node['nginx']['source']['sbin_path']}"
]

include_recipe 'nginx::default'