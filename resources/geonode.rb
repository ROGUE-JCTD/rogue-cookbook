actions :install, :sync_db, :load_data, :collect_static, :start, :update_layers, :create_postgis_datastore,
  :update_site, :update_local_settings, :build_html_docs, :stop

default_action :install



attribute :virtual_env_location, :kind_of => String, :name_attribute => true
attribute :python_interpreter, :kind_of => String, :default => "python2.7"
attribute :branch, :kind_of => String, :default => "master"
attribute :python_packages, :kind_of => Array, :default => node['rogue']['rogue_geonode']['python_packages']
attribute :rogue_geonode_location, :kind_of => String, :default => node['rogue']['rogue_geonode']['location']
attribute :rogue_geonode_branch, :kind_of => String, :default => node['rogue']['rogue_geonode']['branch']
attribute :fixtures, :kind_of => Array, :default => node['rogue']['rogue_geonode']['fixtures']
attribute :logging_location, :kind_of => String, :default => node['rogue']['logging']['location']
attribute :settings, :kind_of => Array, :default => node['rogue']['rogue_geonode']['settings']
attribute :site_domain, :kind_of => String, :default => node['rogue']['networking']['application']['fqdn']
attribute :site_name, :kind_of => String, :default => 'ROGUE'
attribute :geoserver_password, :kind_of => String, :required => false
attribute :rabbitmq_password, :kind_of => String, :required => false
attribute :data_store_password, :kind_of => String, :required => false
attribute :database_password, :kind_of => String, :required => false
attribute :geonode_admin_password_hash, :kind_of => String
attribute :geonode_admin_user, :kind_of => String, :default => node['rogue']['geonode']['admin_user']
