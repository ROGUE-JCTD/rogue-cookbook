gem_package "ruby-shadow" do
  action :install
end

user node['rogue']['user']['username'] do
  home '/home/rogue'
  shell '/bin/bash'
  manage_home true
end

user 'celery'

group 'celery' do
  members 'celery'
end

group "rogue" do
  append true
  members ["rogue", "celery"]
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
end

directory '/var/log/celery' do
  group "rogue"
  owner "celery"
  mode 0755
end
