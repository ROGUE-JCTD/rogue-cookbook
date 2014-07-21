git "/opt/stig" do
  repository node['rogue']['stig']['url']
  revision node['rogue']['stig']['branch']
  action :sync
end
