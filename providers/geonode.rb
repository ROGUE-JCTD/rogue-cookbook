require 'json'
require 'net/http'

def whyrun_supported?
  true
end

use_inline_resources


def django_command(cmd, options)
  "#{new_resource.virtual_env_location}bin/python manage.py #{cmd} #{options.join(' ')}"
end

def collect_static
  execute "collect_static" do
    command django_command('collectstatic', ['--noinput'])
    cwd new_resource.rogue_geonode_location
    user 'root'
  end

  execute "set_rogue_geonode_permissions" do
    command "chmod -R 755 #{new_resource.rogue_geonode_location}"
  end
end


action :install do
  if test
    Chef::Log.debug "Installing GeoNode"

    python_virtualenv new_resource.virtual_env_location do
      interpreter new_resource.python_interpreter
      action :create
    end

    bash "downgrade_pip" do
      code "#{new_resource.virtual_env_location}/bin/easy_install pip==1.4.1"
    end

    for pkg in new_resource.python_packages do
      python_pip pkg do
        virtualenv new_resource.virtual_env_location
      end
    end

    Chef::Log.debug "Pulling ROGUE GeoNode from Git"

    branch = new_resource.rogue_geonode_branch

    if branch == 'maploom'
      Chef::Log.warn('The maploom branch has been merged into master, please update your run list or Vagrant file.')
      branch = 'master'
    end

    git new_resource.rogue_geonode_location do
      repository node['rogue']['rogue_geonode']['url']
      revision branch
      action :sync
    end

    Chef::Log.debug "Installing ROGUE using PIP"
    python_pip new_resource.rogue_geonode_location do
      virtualenv new_resource.virtual_env_location
      options '-e'
    end

    python_pip node['rogue']['django_maploom']['url'] do
      virtualenv new_resource.virtual_env_location
      action :upgrade
      options "--no-deps"
    end

    template "rogue_geonode_config" do
       path "#{new_resource.rogue_geonode_location}/rogue_geonode/local_settings.py"
       source "local_settings.py.erb"
       variables ({:database => node['rogue']['rogue_geonode']['settings']['DATABASES']['default'],
                   :data_store => node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports']})
     end

    collect_static

    Chef::Log.debug "Adding a script to start GeoNode on reboot"
    file "/etc/cron.d/geonode_restart" do
      content "@reboot root /bin/bash #{new_resource.rogue_geonode_location}/start_geonode.sh\n"
      mode 00755
      action :create_if_missing
    end

    directory new_resource.logging_location do
      action :create
    end

    Chef::Log.debug "Creating the GeoNode uwsgi configuration file"
    template "rogue_geonode_uwsgi_config" do
      path "#{new_resource.rogue_geonode_location}/django.ini"
      source "django.ini.erb"
    end
    new_resource.updated_by_last_action(true)
  end
end

action :sync_db do
  execute "sync_db_#{new_resource.rogue_geonode_location}" do
    command django_command('syncdb', ['--all', '--noinput'])
    cwd new_resource.rogue_geonode_location
    user 'root'
    not_if "cd #{new_resource.rogue_geonode_location} && #{django_command('dumpdata', ['security'])}"
  end
  new_resource.updated_by_last_action(true)
end

action :load_data do
  execute "load_data" do
    command django_command('loaddata', new_resource.fixtures)
    cwd new_resource.rogue_geonode_location
    user 'root'
  end
  new_resource.updated_by_last_action(true)
end

action :collect_static do
  collect_static
end

action :start do
  execute "runserver" do
    command "#{new_resource.virtual_env_location}bin/uwsgi --ini #{new_resource.rogue_geonode_location}/django.ini &"
    user 'root'
    not_if "pgrep uwsgi"
  end
end

action :update_layers do
  execute "update_layers" do
    command django_command('updatelayers', ['--ignore-errors'])
    cwd new_resource.rogue_geonode_location
    user 'root'
    action :run
    retries 8
  end
  new_resource.updated_by_last_action(true)
end

action :create_postgis_datastore do
  template "/tmp/newDataStore.xml" do
    source "newDataSource.xml.erb"
    variables ({ :settings => new_resource.settings })
  end


  credentials = new_resource.settings["OGC_SERVER"]["USER"] + ':' + new_resource.settings["OGC_SERVER"]["PASSWORD"]
  bash "create_geonode_imports_datastore" do
    code 'curl -v -u ' + credentials + ' -XPOST -H "Content-type: text/xml" -d @/tmp/newDataStore.xml ' + new_resource.settings["OGC_SERVER"]["LOCATION"] + 'rest/workspaces/geonode/datastores.xml'
    ignore_failure true
    not_if do
  	  uri = URI.parse("#{new_resource.settings['OGC_SERVER']['LOCATION']}rest/workspaces/geonode/datastores.json")
  	  req = Net::HTTP::Get.new(uri.to_s)
  	  req.basic_auth new_resource.settings['OGC_SERVER']['USER'], new_resource.settings['OGC_SERVER']['PASSWORD']
  	  resp = Net::HTTP.new(uri.host, uri.port).start{|http| http.request(req)}
  	  resp.body.include? 'geonode_imports'
    end
    retries 8
    retry_delay 10
  end

  file "/tmp/newDataStore.xml" do
    action :delete
  end

  new_resource.updated_by_last_action(true)
end

def test()
  true
end