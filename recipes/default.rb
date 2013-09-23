geonode_pkgs =  "build-essential libxml2-dev libxslt-dev".split

geonode_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

python_virtualenv node['rogue']['geonode']['location'] do
  interpreter "python2.7"
  action :create
end

git node['rogue']['rogue_geonode']['location'] do
  repository node['rogue']['rogue_geonode']['url']
  revision node['rogue']['rogue_geonode']['branch']
  action :sync
end

python_pip node['rogue']['rogue_geonode']['location'] do
  virtualenv node['rogue']['geonode']['location']
end

for pkg in "libpq-dev python-dev".split do
  apt_package pkg do
    action :install
  end
end

for pkg in "uwsgi psycopg2" do
  python_pip pkg do
    virtualenv node['rogue']['geonode']['location']
  end  
end

#TODO work on this.
template "#{node['rogue']['rogue_geonode']['location']}/rogue_geonode/local_settings.py" do
  source "local_settings.py.erb"
  variables ({:database => node['rogue']['rogue_geonode']['settings']['DATABASES']['default']})
end

template File.join(node['nginx']['dir'], 'proxy.conf') do
  source 'proxy.conf.erb'
end

# This is what we used to do.
#link "#{node['nginx']['dir']}/sites-enabled/nginx.conf" do
#  link_type :symbolic
#  action :create
#  to File.join(node['rogue']['rogue_geonode']['location'], 'nginx.conf')
#end

template "#{node['nginx']['dir']}/sites-enabled/nginx.conf" do
  source "nginx.conf.erb"
  variables ({:proxy_conf => "#{node['nginx']['dir']}/proxy.conf"})
end

template "#{node['rogue']['rogue_geonode']['location']}/django.ini" do
  source "django.ini.erb"
end

service "nginx" do
  action :restart
end

["collectstatic --noinput", "syncdb --all --noinput", "loaddata sample_admin.json"].each do |cmd|
  execute "#{node['rogue']['interpreter']} manage.py #{cmd}" do
    cwd node['rogue']['rogue_geonode']['location']
    user 'root'
  end
end

execute "change permissions" do
  command "chmod -R 755 #{node['rogue']['geonode']['location']}"
end

execute "runserver" do
  command "#{node['rogue']['geonode']['location']}/bin/uwsgi --ini #{node['rogue']['rogue_geonode']['location']}/django.ini &"
  user 'root'
end

log "Rogue is now runnning on #{node['rogue']['host_only']}."
