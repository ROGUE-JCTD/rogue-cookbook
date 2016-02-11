require 'json'
require 'net/http'
require 'net/https'

include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

use_inline_resources

def django_command(cmd, options=[])
  "#{new_resource.virtual_env_location}bin/python manage.py #{cmd} #{options.join(' ')}"
end

def set_perms(directory, perm=570)
  execute "chmod #{perm} #{directory} -R && chown www-data:#{node['rogue']['user']['username']} #{directory} -R"
end

def collect_static
  set_perms(new_resource.settings['STATIC_ROOT'], 775)
  set_perms(new_resource.settings['MEDIA_ROOT'], 775)

  execute "collect_static" do
    command django_command('collectstatic', ['--noinput'])
    cwd new_resource.rogue_geonode_location
  end
end

def local_settings(template_variables={})
  variables = {
    :database => node['rogue']['rogue_geonode']['settings']['DATABASES']['default'],
    :data_store => node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports'],
    :data_store_password => new_resource.data_store_password,
    :database_password => new_resource.database_password,
    :geoserver_password => new_resource.geoserver_password,
    :debug => node['rogue']['debug'],
    :rabbitmq_username => node['rabbitmq']['rogue_user'][:name],
    :rabbitmq_password => new_resource.rabbitmq_password,
    :rabbitmq_address => node['rabbitmq']['address'],
    :rabbitmq_port => node['rabbitmq']['port'],
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

#    osgeo_library = '/usr/lib/python2.7/dist-packages/'
#    site_packages = ::File.join(new_resource.virtual_env_location, 'lib/python2.7/site-packages/')
#
#    bash "add_virtual_path" do
#      code "echo #{osgeo_library} > #{site_packages}_virtualenv_path_extensions.pth"
#      #only_if { ::File.exists? osgeo_library and !::File.exists? ::File.join(site_packages, '_virtualenv_path_extensions.pth')}
#      cwd site_packages
#    end
    
    bash "downgrade_pip" do
      code "#{new_resource.virtual_env_location}/bin/easy_install pip==1.4.1"
      not_if "#{new_resource.virtual_env_location}/bin/pip -V | grep 1.4.1"
    end
    
    for pkg in new_resource.python_packages do
      python_pip pkg do
        virtualenv new_resource.virtual_env_location
      end
    end
      
    bash "downgrade_pip" do
      code "#{new_resource.virtual_env_location}/bin/easy_install pip==1.4.1"
      not_if "#{new_resource.virtual_env_location}/bin/pip -V | grep 1.4.1"
    end
 
    for pkg in new_resource.python_packages do
      python_pip pkg do
        virtualenv new_resource.virtual_env_location
      end
    end

     bash "local_httplib2_install" do
        code "#{new_resource.virtual_env_location}/bin/pip install httplib2"
        not_if {::File.exists?("/var/lib/geonode/lib/python2.7/site-packages/httplib2")}
      end

      if node.create_self_signed_cert && !node.certs.empty?
        cacerts = "#{node.rogue.geonode.location}local/lib/python2.7/site-packages/httplib2/cacerts.txt"

        node.certs.each{ |cert|
          execute "cat #{cert} >> #{cacerts}" do
            not_if {IO.read(cacerts).include?(IO.read(cert))}
            only_if "test -f #{cacerts}"
          end
        }
      end

      link '/var/lib/geonode/lib/python2.7/site-packages/osgeo' do
        to '/usr/lib/python2.7/dist-packages/osgeo'
      end
        
      link '/var/lib/geonode/lib/python2.7/site-packages/gdalconst.py' do
        to '/usr/lib/python2.7/dist-packages/gdalconst.py'
      end

      link '/var/lib/geonode/lib/python2.7/site-packages/gdalconst.pyc' do
        to '/usr/lib/python2.7/dist-packages/gdalconst.pyc'
      end

      link '/var/lib/geonode/lib/python2.7/site-packages/gdalnumeric.py' do
        to '/usr/lib/python2.7/dist-packages/gdalnumeric.py'
      end

      link '/var/lib/geonode/lib/python2.7/site-packages/gdalnumeric.pyc' do
        to '/usr/lib/python2.7/dist-packages/gdalnumeric.pyc'
      end

      link '/var/lib/geonode/lib/python2.7/site-packages/gdal.py' do
        to '/usr/lib/python2.7/dist-packages/gdal.py'
      end
      
      link '/var/lib/geonode/lib/python2.7/site-packages/gdal.pyc' do
        to '/usr/lib/python2.7/dist-packages/gdal.pyc'
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
      timeout 1500
    end

    Chef::Log.debug "Installing ROGUE using PIP"

    pip_install = new_resource.rogue_geonode_location
    if node['rogue']['install_docs']
      pip_install = "#{new_resource.rogue_geonode_location}[docs]"
    end

    python_pip pip_install do
      virtualenv new_resource.virtual_env_location
      options "-e"
      not_if "find /var/lib/geonode/lib/python2.7/site-packages -name geonode_*egg-info | grep geonode_"
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
  if !new_resource.fixtures.empty?
    template "#{node['rogue']['geonode']['location']}lib/python2.7/site-packages/geonode/people/fixtures/sample_admin.json" do
      source "geonode_users.json.erb"
      variables(
        :password_hash => new_resource.geonode_admin_password_hash,
        :username => new_resource.geonode_admin_user
      )
    end

    execute "load_data_#{new_resource.name}" do
      command django_command('loaddata', new_resource.fixtures)
      cwd new_resource.rogue_geonode_location
      only_if { !new_resource.fixtures.empty? }
      ignore_failure true
    end

    new_resource.updated_by_last_action(true)
  end
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
      not_if "service celeryd status | grep running"
    end

    service "celeryd" do
      action :start
      not_if "service celeryd status | grep running"
    end
end

action :stop do
    execute "stop_rogue" do
      command 'supervisorctl stop rogue'
    end

    execute "stop_rogue-celery" do
      command 'supervisorctl stop rogue-celery'
      returns [0, 1]
    end

    service "celeryd" do
      action :stop
    end
end

action :update_layers do
  cmd = shell_out("cd #{new_resource.rogue_geonode_location} && #{django_command('updatelayers', ['--ignore-errors'])}")
  if cmd.exitstatus == 0
    Chef::Log.info("update_layers #{cmd.stdout}")
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.error("failed to run update_layers. Error: #{cmd.stderr}")
    
    if node.ssl && !node.certs.empty?
      cacerts = "#{node.rogue.geonode.location}local/lib/python2.7/site-packages/httplib2/cacerts.txt"
      node.certs.each{ |cert|
        `cat #{cert} >> #{cacerts}` if !IO.read(cacerts).include?(IO.read(cert))
      }
    end

    `service nginx restart`
    `service tomcat7 restart && sleep 20`

    update_layers = shell_out("cd #{new_resource.rogue_geonode_location} && #{django_command('updatelayers', ['--ignore-errors'])}")
    Chef::Log.error("Retried update_layers stderr: #{update_layers.stderr}. stdout: #{update_layers.stdout}")
    new_resource.updated_by_last_action(true) if update_layers.exitstatus == 0
  end

  # execute "update_layers" do
    # command django_command('updatelayers', ['--ignore-errors'])
    # cwd new_resource.rogue_geonode_location
    # action :run
    # retries 8
  # end
end

action :create_postgis_datastore do  
  uri = URI.parse("#{new_resource.settings['OGC_SERVER']['LOCATION']}rest/workspaces/geonode/datastores.json")
  http = Net::HTTP.new(uri.host, uri.port)

  if node.ssl
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth(new_resource.settings['OGC_SERVER']['USER'], new_resource.geoserver_password)
  resp = http.request(req)

  unless resp.body.include?('geonode_imports')
    template "#{Chef::Config[:file_cache_path]}/newDataStore.xml" do
      source "newDataSource.xml.erb"
      variables ({ :settings => new_resource.settings, :data_store_password => new_resource.data_store_password })
    end

    credentials = "#{new_resource.settings["OGC_SERVER"]["USER"]}:'#{new_resource.geoserver_password}'"

    bash "create_geonode_imports_datastore" do
      code "curl -v -u #{credentials} -XPOST -H 'Content-type: text/xml' -d @#{Chef::Config[:file_cache_path]}/newDataStore.xml #{new_resource.settings['OGC_SERVER']['LOCATION']}rest/workspaces/geonode/datastores.xml"
      retries 8
      retry_delay 10
    end

    new_resource.updated_by_last_action(true)
  end
end

action :build_html_docs do
  bash "build docs" do
    code "source #{new_resource.virtual_env_location}/bin/activate && cd #{new_resource.rogue_geonode_location}/docs && make html && chmod 574 build -R && chown www-data:#{node['rogue']['user']['username']} build -R"
    only_if { node['rogue']['install_docs'] }
    not_if { ::Dir.exists?("#{new_resource.rogue_geonode_location}/docs/build/html") }
  end
end

def test()
  true
end
