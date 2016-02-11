include_recipe 'nginx'

directory node.nginx.webdir do
  owner node.nginx.user
  group node.tomcat.group
end
