git node['rogue']['iaff_geoshape']['location'] do
  repository node['rogue']['iaff_geoshape']['url']
  revision node['rogue']['iaff_geoshape']['branch']
  action :sync
end

python_pip node['rogue']['iaff_geoshape']['location'] do
  virtualenv node['rogue']['geonode']['location']
  options "-e"
end

execute "sync_db" do
  command "#{node['rogue']['geonode']['location']}bin/python #{node['rogue']['rogue_geonode']['location']}/manage.py syncdb --database=geonode_imports --no-initial-data --all"
end


file "/etc/cron.d/geoshape_update_data" do
  content "* 30 * * * rogue /var/lib/geonode/bin/python /var/lib/geonode/rogue_geonode/manage.py update_data\n"
  mode 00755
  action :create_if_missing
end
