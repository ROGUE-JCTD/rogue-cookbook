node.default['postgis']['version'] = '2.1'
node.default['postgis']['template_name'] = 'template_postgis'
node.default['postgis']['locale'] = 'en_US.utf8'

if node['postgis']['template_name']
  execute 'create_postgis_template' do
    not_if "psql -qAt --list | grep -q '^#{node['postgis']['template_name']}\|'", :user => 'postgres'
    user 'postgres'
    command <<-CMD
    (createdb -E UTF8 --locale=#{node['postgis']['locale']} #{node['postgis']['template_name']} -T template0) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/postgis.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/spatial_ref_sys.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/postgis_comments.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/rtpostgis.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/raster_comments.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/topology.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/topology_comments.sql) &&
    (psql -d #{node['postgis']['template_name']} -f `pg_config --sharedir`/contrib/postgis-2.1/legacy.sql)
    CMD
    action :run
  end
end
