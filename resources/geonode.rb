actions :install, :syncdb, :load_data, :collect_static, :start, :update_layers
default_action :install



attribute :virtual_env_location, :kind_of => String, :name_attribute => true
attribute :python_interpreter, :kind_of => String, :default => "python2.7"
attribute :branch, :kind_of => String, :default => "master"
attribute :python_packages, :kind_of => Array, :default => ["uwsgi", "psycopg2"]
attribute :rogue_geonode_location, :kind_of => String, :default => node['rogue']['rogue_geonode']['location']
attribute :rogue_geonode_branch, :kind_of => String, :default => node['rogue']['rogue_geonode']['branch']
attribute :fixtures, :kind_of => Array, :default => node['rogue']['rogue_geonode']['fixtures']
attribute :logging_location, :kind_of => String, :default => node['rogue']['logging']['location']


