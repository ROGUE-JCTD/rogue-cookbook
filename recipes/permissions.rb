gem_package "ruby-shadow" do
  action :install
end

user node['rogue']['user']['username'] do
  home '/home/rogue'
  supports :manage_home => true
  shell '/bin/bash'
  gid 'sudo'
  password node['rogue']['user']['password']
end

group "roguecat" do
  action :create
  append true
  members "rogue"
end