node.set['postgresql']['password']['postgres'] = 'rogue'
node.set['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '192.168.10.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

include_recipe 'postgis'

gem_package "pg" do
  action :install
end

postgresql_connection_info = {
  :host     => 'localhost',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

geonode_connection_info = node['rogue']['rogue_geonode']['settings']['DATABASES']['default']
geonode_imports_connection_info = node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports']

# Create the GeoNode user
postgresql_database_user geonode_connection_info[:user] do
    connection postgresql_connection_info
    password geonode_connection_info[:password]
    action :create
end

# Create the GeoNode database
postgresql_database geonode_connection_info[:name] do
  connection postgresql_connection_info
  owner geonode_connection_info[:user]
  action :create
end

# Create the GeoNode imports user
postgresql_database_user geonode_imports_connection_info[:user] do
    connection postgresql_connection_info
    password geonode_imports_connection_info[:password]
    action :create
end

# Create the GeoNode imports db
postgresql_database geonode_imports_connection_info[:name] do
  connection postgresql_connection_info
  template node['postgis']['template_name']
  owner geonode_imports_connection_info[:user]
  action :create
end

postgresql_database 'set user' do
  connection   postgresql_connection_info
  database_name geonode_imports_connection_info[:name]
  sql 'grant select on geometry_columns, spatial_ref_sys to ' + geonode_imports_connection_info[:user] + ';'
  action :query
end

