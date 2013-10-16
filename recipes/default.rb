geonode_pkgs =  "build-essential libxml2-dev libxslt-dev libjpeg-dev zlib1g-dev libpng12-dev libpq-dev python-dev".split

geonode_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

source = "/usr/lib/x86_64-linux-gnu/libjpeg.so"
target = "/usr/lib/libjpeg.so"
# This fixes https://github.com/ROGUE-JCTD/rogue_geonode/issues/17
link target do
  to source
  not_if do
    File.exists?(target) or !File.exists?(source)
  end
  action :create
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

for pkg in "uwsgi psycopg2".split do
  python_pip pkg do
    virtualenv node['rogue']['geonode']['location']
  end  
end

#TODO work on this.
template "#{node['rogue']['rogue_geonode']['location']}/rogue_geonode/local_settings.py" do
  source "local_settings.py.erb"
  variables ({:database => node['rogue']['rogue_geonode']['settings']['DATABASES']['default'],
              :data_store => node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports']
            })
end

template File.join(node['nginx']['dir'], 'proxy.conf') do
  source 'proxy.conf.erb'
end

template "#{node['nginx']['dir']}/sites-enabled/nginx.conf" do
  source "nginx.conf.erb"
  variables ({:proxy_conf => "#{node['nginx']['dir']}/proxy.conf"})
  notifies :reload, "service[nginx]"
end

template "#{node['rogue']['rogue_geonode']['location']}/django.ini" do
  source "django.ini.erb"
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

runserver = "#{node['rogue']['geonode']['location']}bin/uwsgi --ini #{node['rogue']['rogue_geonode']['location']}/django.ini &"

execute "runserver" do
  command runserver
  user 'root'
end

log "Rogue is now running on #{node['rogue']['host_only']}."
