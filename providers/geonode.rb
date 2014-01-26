def whyrun_supported?
  true
end

use_inline_resources

def django_command(cmd, options)
    "#{new_resource.virtual_env_location}/bin/python manage.py #{cmd} #{options.join(' ')}"
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
    git new_resource.rogue_geonode_location do
     repository node['rogue']['rogue_geonode']['url']
     revision new_resource.rogue_geonode_branch
     action :sync
    end

    Chef::Log.debug "Installing ROGUE using PIP"
    python_pip new_resource.rogue_geonode_location do
     virtualenv new_resource.virtual_env_location
     # notifies :run, "execute[collect_static]" ## where do we put this?
    end

    python_pip node['rogue']['django_maploom']['url'] do
     virtualenv new_resource.virtual_env_location
     action :upgrade
     options "--no-deps"
     only_if { node['rogue']['rogue_geonode']['branch'] == 'maploom' }
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

action :syncdb do
  execute "sync_db" do
    command django_command('syncdb', ['--all', '--noinput'])
    cwd new_resource.rogue_geonode_location
    user 'root'
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
end


def test()
  true
end