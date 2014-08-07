git node['rogue']['rogue-scripts']['location'] do
  repository node['rogue']['rogue-scripts']['url']
  revision node['rogue']['rogue-scripts']['branch']
  action :sync
end

file "/etc/profile.d/rogue-scripts.sh" do
  content "export PATH=$PATH:#{::File.join(node['rogue']['rogue-scripts']['location'],'bin')}"
  mode 00755
  action :create
end

bash "Update path" do
  code "export PATH=$PATH:#{::File.join(node['rogue']['rogue-scripts']['location'],'bin')}"
end
