require 'json'
require 'net/http'

def whyrun_supported?
  true
end

use_inline_resources

def django_command(cmd, options=[])
  "#{new_resource.virtual_env_location}bin/python manage.py #{cmd} #{options.join(' ')}"
end

def set_perms(directory, perm=570)
  bash "set_file_permissions" do
    code "chmod #{perm} #{directory} -R && chown www-data:#{node['rogue']['user']['username']} #{directory} -R"
  end
end

def collect_static
  directory new_resource.settings['STATIC_ROOT'] do
    group "rogue"
    owner "www-data"
    mode 0755
  end

  directory new_resource.settings['MEDIA_ROOT'] do
    group "rogue"
    owner "www-data"
    mode 0755
  end

  directory new_resource.settings['MEDIA_ROOT'] + "/thumbs" do
    group "rogue"
    owner "www-data"
    mode 0755
  end

  execute "collect_static" do
    command django_command('collectstatic', ['--noinput'])
    cwd new_resource.rogue_geonode_location
  end

  set_perms(new_resource.settings['STATIC_ROOT'], 775)
  set_perms(new_resource.settings['MEDIA_ROOT'], 775)

end

def local_settings(template_variables={})
  variables = {:database => node['rogue']['rogue_geonode']['settings']['DATABASES']['default'],
                :data_store => node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'],
                :settings => new_resource.settings
               }.merge(template_variables)

  template "rogue_geonode_config" do
    path "#{new_resource.rogue_geonode_location}/geoshape/local_settings.py"
    source "local_settings.py.erb"
    variables(variables)
  end
end

action :install do
  if test
    Chef::Log.debug "Installing GeoNode"

    python_virtualenv new_resource.virtual_env_location do
      interpreter new_resource.python_interpreter
      action :create
    end

    osgeo_library = '/usr/lib/python2.6/dist-packages/'
    site_packages = ::File.join(new_resource.virtual_env_location, 'lib/python2.7/site-packages/')

    bash "add_virtual_path" do
      code "echo #{osgeo_library} > #{site_packages}_virtualenv_path_extensions.pth"
      #only_if { ::File.exists? osgeo_library and !::File.exists? ::File.join(site_packages, '_virtualenv_path_extensions.pth')}
      cwd site_packages
    end

    bash "downgrade_pip" do
      code "#{new_resource.virtual_env_location}/bin/easy_install pip==1.4.1"
    end

    for pkg in new_resource.python_packages do
      python_pip pkg do
        virtualenv new_resource.virtual_env_location
      end
    end

    bash "virtual_env permissions" do
      code "chmod 570 #{new_resource.virtual_env_location} -R && chown www-data:#{node['rogue']['user']['username']} #{new_resource.virtual_env_location} -R"
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

    pip_install = new_resource.rogue_geonode_location
    if node['rogue']['install_docs']
      pip_install = "#{new_resource.rogue_geonode_location}[docs]"
    end

    python_pip pip_install do
      virtualenv new_resource.virtual_env_location
      options "--use-mirrors -e"
    end

    python_pip node['rogue']['django_maploom']['url'] do
      virtualenv new_resource.virtual_env_location
      action :upgrade
      options "--no-deps"
      only_if { node['rogue']['django_maploom']['auto_upgrade'] }
    end

    local_settings
    collect_static

    directory new_resource.logging_location do
      action :create
      owner 'www-data'
      group 'rogue'
      mode 0370
    end

    Chef::Log.debug "Creating the GeoNode uwsgi configuration file"
    template "rogue_geonode_uwsgi_config" do
      path "#{new_resource.rogue_geonode_location}/django.ini"
      source "django.ini.erb"
    end

    set_perms(new_resource.rogue_geonode_location)
    new_resource.updated_by_last_action(true)

    supervisord_program 'rogue' do
      name 'rogue'
      command "#{new_resource.virtual_env_location}bin/uwsgi --ini #{new_resource.rogue_geonode_location}/django.ini"
      autorestart true
      action :supervise
    end

    supervisord_program 'rogue-celery' do
      name 'rogue-celery'
      command "service celeryd start"
      autorestart true
      action :supervise
    end

  end
end

action :sync_db do
  execute "sync_db_#{new_resource.rogue_geonode_location}" do
    command django_command('syncdb', ['--noinput'])
    cwd new_resource.rogue_geonode_location
  end

  new_resource.updated_by_last_action(true)
end

action :update_site do
  execute "update_site_domain" do
    command django_command('siteupdate', ["-d #{new_resource.site_domain}", "-n #{new_resource.site_name}"] )
    cwd new_resource.rogue_geonode_location
  end
end

action :load_data do
  execute "load_data_#{new_resource.name}" do
    command django_command('loaddata', new_resource.fixtures)
    cwd new_resource.rogue_geonode_location
    only_if { new_resource.fixtures }
    ignore_failure true
  end
  new_resource.updated_by_last_action(true)
end

action :update_local_settings do
    local_settings
end

action :collect_static do
  collect_static
end

action :start do
    execute "start_rogue" do
      command 'supervisorctl start rogue'
      not_if "supervisorctl status rogue | grep RUNNING"
    end

    execute "start_rogue-celery" do
      command 'supervisorctl start rogue-celery'
      not_if "supervisorctl status rogue-celery | grep RUNNING"
    end
end

action :stop do
    execute "stop_rogue" do
      command 'supervisorctl stop rogue'
    end
end

action :update_layers do
  execute "update_layers" do
    command django_command('updatelayers', ['--ignore-errors'])
    cwd new_resource.rogue_geonode_location
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
    code "curl -v -u #{credentials} -XPOST -H 'Content-type: text/xml' -d @/tmp/newDataStore.xml #{new_resource.settings['OGC_SERVER']['LOCATION']}rest/workspaces/geonode/datastores.xml"
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

action :build_html_docs do
  bash "build docs" do
    code "source #{new_resource.virtual_env_location}/bin/activate && cd #{new_resource.rogue_geonode_location}/docs && make html && chmod 574 build -R && chown www-data:#{node['rogue']['user']['username']} build -R"
    only_if { node['rogue']['install_docs'] }
  end


end

def test()
  true
end
