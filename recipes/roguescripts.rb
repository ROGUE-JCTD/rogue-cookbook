git node['rogue']['rogue-scripts']['location'] do
  repository node['rogue']['rogue-scripts']['url']
  revision node['rogue']['rogue-scripts']['branch']
  action :sync
end

file "/etc/profile.d/rogue-scripts.sh" do
  content "export PATH=$PATH:#{node['rogue']['rogue-scripts']['location']}/bin"
  mode 0755
end

bash "Update path" do
  code "export PATH=$PATH:#{node['rogue']['rogue-scripts']['location']}/bin"
  not_if "echo $PATH | grep #{node['rogue']['rogue-scripts']['location']}/bin"
end
