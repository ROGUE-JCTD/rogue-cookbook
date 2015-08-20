node.default['postgresql']['password']['postgres'] = node['rogue']['postgresql']['password']
node.default['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '192.168.10.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

# Add the postgres dev server to the installation
#node.default['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']} postgresql-server-dev-#{node['postgresql']['version']}"]

include_recipe 'build-essential'
include_recipe 'postgresql::server'
include_recipe 'rogue::postgis'

