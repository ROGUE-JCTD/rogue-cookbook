node.normal.postgresql.password.postgres = node.rogue.postgresql.password
default.postgresql.pg_hba = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

default['postgis']['version'] = '2.1'
default['postgis']['template_name'] = 'template_postgis'
default['postgis']['locale'] = 'en_US.utf8'

node.normal.postgresql.enable_pgdg_apt = true
node.normal.postgresql.version = "9.4"
node.normal.postgresql.client.packages = ["postgresql-client-#{node.postgresql.version}", "libpq-dev"]
node.normal.postgresql.server.packages = ["postgresql-#{node.postgresql.version}"]
node.normal.postgresql.contrib.packages = ["postgresql-contrib-#{node.postgresql.version}"]
# Chef can be funny sometimes, even though these are declared exactly the same in the postgresql cookbook, 
# Chef still fails on the first run because these still use the version of postgres declared in the cookbook
node.normal.postgresql.dir = "/etc/postgresql/#{node.postgresql.version}/main"
node.normal.postgresql.config.data_directory = "/var/lib/postgresql/#{node.postgresql.version}/main"
