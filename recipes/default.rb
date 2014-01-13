geonode_pkgs =  "build-essential libxml2-dev libxslt-dev libjpeg-dev zlib1g-dev libpng12-dev libpq-dev python-dev maven".split

geonode_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe 'rogue::permissions'
include_recipe 'rogue::java'
include_recipe 'rogue::tomcat'
include_recipe 'rogue::nginx'
include_recipe 'rogue::geogit'
include_recipe 'rogue::networking'
include_recipe 'rogue::unison'

source = "/usr/lib/x86_64-linux-gnu/libjpeg.so"
target = "/usr/lib/libjpeg.so"
# This fixes https://github.com/ROGUE-JCTD/rogue_geonode/issues/17
link target do
  to source
  not_if do File.exists?(target) or !File.exists?(source) end
  action :create
end

python_virtualenv node['rogue']['geonode']['location'] do
  interpreter "python2.7"
  action :create
end

bash "downgrade_pip" do
  code "#{node['rogue']['geonode']['location']}/bin/easy_install pip==1.4.1"
end

for pkg in "uwsgi psycopg2".split do
  python_pip pkg do
    virtualenv node['rogue']['geonode']['location']
  end
end

git node['rogue']['rogue_geonode']['location'] do
  repository node['rogue']['rogue_geonode']['url']
  revision node['rogue']['rogue_geonode']['branch']
  action :sync
end

python_pip node['rogue']['rogue_geonode']['location'] do
  virtualenv node['rogue']['geonode']['location']   
  notifies :run, "execute[collect_static]"
end

if node['rogue']['rogue_geonode']['branch'] == 'maploom'
    python_pip node['rogue']['django_maploom']['url'] do
      virtualenv node['rogue']['geonode']['location']
      action :upgrade
      options "--no-deps"
    end
end

include_recipe 'rogue::geoserver'

template "rogue_geonode_config" do
  path "#{node['rogue']['rogue_geonode']['location']}/rogue_geonode/local_settings.py"
  source "local_settings.py.erb"
  variables ({:database => node['rogue']['rogue_geonode']['settings']['DATABASES']['default'],
              :data_store => node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports']})
end

include_recipe 'rogue::database'

template "nginx_proxy_config" do
  path File.join(node['nginx']['dir'], 'proxy.conf')
  source 'proxy.conf.erb'
end

template "rogue_geonode_nginx_config" do
  path "#{node['nginx']['dir']}/sites-enabled/nginx.conf"
  source "nginx.conf.erb"
  variables ({:proxy_conf => "#{node['nginx']['dir']}/proxy.conf"})
  notifies :reload, "service[nginx]", :immediately
end

directory node['rogue']['logging']['location'] do
  action :create
end

template "rogue_geonode_uwsgi_config" do
  path "#{node['rogue']['rogue_geonode']['location']}/django.ini"
  source "django.ini.erb"
end

# Create the GeoGIT datastore directory
directory node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['GEOGIT_DATASTORE_DIR'] do
    owner node["tomcat"]["user"]
    recursive true
    mode 00755
end

execute "collect_static" do
  command "#{node['rogue']['interpreter']} manage.py collectstatic --noinput"
  cwd node['rogue']['rogue_geonode']['location']
  user 'root'
  action :nothing
  notifies :run, "execute[set_rogue_geonode_permissions]"
end

execute "sync_db" do
    command "#{node['rogue']['interpreter']} manage.py syncdb --all --noinput"
    cwd node['rogue']['rogue_geonode']['location']
    user 'root'
    ignore_failure true
    action :nothing
end

fixtures = "sample_admin.json #{node['rogue']['rogue_geonode']['location']}/rogue_geonode/fixtures/initial_data.json"
execute "load_sample_data" do
    command "#{node['rogue']['interpreter']} manage.py loaddata  #{fixtures}"
    cwd node['rogue']['rogue_geonode']['location']
    user 'root'
    ignore_failure true
    action :nothing
end

execute "set_rogue_geonode_permissions" do
  command "chmod -R 755 #{node['rogue']['geonode']['location']}"
  action :nothing
end

file "/etc/cron.d/geonode_restart" do
  content "@reboot root /bin/bash #{node['rogue']['rogue_geonode']['location']}/start_geonode.sh\n"
  mode 00755
  action :create_if_missing
end

runserver = "#{node['rogue']['geonode']['location']}bin/uwsgi --ini #{node['rogue']['rogue_geonode']['location']}/django.ini &"

execute "runserver" do
  command runserver
  user 'root'
end

http_request "create_geonode_imports_datastore" do
  url node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] + 'rest/workspaces/geonode/datastores.xml'
  message :"dataStore"=>
    {"name"=>node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'][:name],
    "type"=>"PostGIS",
    "enabled"=>true,
    "workspace"=>{
        "name"=>"geonode",
        "href"=> node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['LOCATION'] + "/rest/workspaces/geonode.xml"},
        "connectionParameters"=>{
            "entry"=>[{"@key"=>"port","$"=>node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'][:port]},
                    {"@key"=>"passwd","$"=>node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'][:password]},
                    {"@key"=>"dbtype","$"=>"postgis"},
                    {"@key"=>"schema","$"=>"public"},
                    {"@key"=>"max connections", "$"=>"10"},
                    {"@key"=>"min connections", "$"=>"1"},
                    {"@key"=>"Max open prepared statements", "$"=>"50"},
                    {"@key"=>"host","$"=> node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'][:host]},
                    {"@key"=>"user","$"=>node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'][:user]},
                    {"@key"=>"database","$"=>node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'][:name]},
                    ]},
        "_default"=>false,
        }
  action :nothing
  headers({"AUTHORIZATION" => "Basic #{Base64.encode64("#{node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['USER']}:#{node['rogue']['rogue_geonode']['settings']['OGC_SERVER']['PASSWORD']}")}"})
  ignore_failure true
  retries 5
 end

 execute "update_layers" do
  command "#{node['rogue']['interpreter']} manage.py updatelayers --ignore-errors"
  cwd node['rogue']['rogue_geonode']['location']
  user 'root'
  action :run
end

log "Rogue is now running on #{node['rogue']['networking']['application']['address']}."
