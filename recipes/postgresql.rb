include_recipe 'postgresql::server'
package "postgresql-#{node['postgresql']['version']}-postgis-#{node['postgis']['version']}"
