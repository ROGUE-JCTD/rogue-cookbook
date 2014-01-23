def whyrun_supported?
  true
end

use_inline_resources

def django_command(cmd, options)
    "#{new_resource.virtual_env_location}/bin/python manage.py #{cmd} #{options.join(' ')}"
end

action :install do
  if test
    log new_resource.virtual_env_location
    python_virtualenv new_resource.virtual_env_location do
     interpreter new_resource.python_interpreter
     action :create
    end

    bash "downgrade_pip" do
     code "#{new_resource.virtual_env_location}/bin/easy_install pip==1.4.1"
    end

    Chef::Log.debug new_resource.python_packages

    for pkg in new_resource.python_packages do
     python_pip pkg do
      virtualenv new_resource.virtual_env_location
     end
    end

    log "pulling from git"
    git new_resource.rogue_geonode_location do
     repository node['rogue']['rogue_geonode']['url']
     revision new_resource.rogue_geonode_branch
     action :nothing#:sync
    end

    log "pip installing"
    python_pip new_resource.rogue_geonode_location do
     virtualenv new_resource.rogue_geonode_location
     # notifies :run, "execute[collect_static]" ## where do we put this?
    end

    # action :collect_static

    log "Add cronjob to restart"
    file "/etc/cron.d/geonode_restart" do
     content "@reboot root /bin/bash #{new_resource.rogue_geonode_location}/start_geonode.sh\n"
     mode 00755
     action :create_if_missing
    end

    log "setting permissions"
    execute "set_rogue_geonode_permissions" do
     command "chmod -R 755 #{new_resource.rogue_geonode_location}"
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
  execute "collect_static" do
   command django_command('collectstatic', ['--noinput'])
   cwd new_resource.rogue_geonode_location
   user 'root'
  end
end

action :runserver do
  execute "runserver" do
   command "#{new_resource.virtual_env_location}bin/uwsgi --ini #{new_resource.rogue_geonode_location}/django.ini &"
   user 'root'
   not_if "pgrep uwsgi"
  end
end


def test()
  true
end