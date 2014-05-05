gem_package "ruby-shadow" do
  action :install
end

user node['rogue']['user']['username'] do
  home '/home/rogue'
  supports :manage_home => true
  shell '/bin/bash'
  password node['rogue']['user']['password']
end

group "rogue" do
  action :create
  append true
  members "rogue"
end

group "sudo" do
  action :modify
  members "rogue"
  append true
end

group "roguecat" do
  action :create
  append true
  members "rogue"
end

user "unison" do
  shell '/bin/bash'
  home '/home/unison'
  password node['unison']['user']['password']
end

group "roguecat" do
  action :modify
  append true
  members "unison"
end