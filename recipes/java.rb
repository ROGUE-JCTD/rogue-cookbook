node.set['java']['oracle']['accept_oracle_download_terms'] = true
node.set['java']['install_flavor']= "oracle"

include_recipe "java::default"
include_recipe "java::oracle"

# clean this up
jdk = '/usr/lib/jvm/jdk1.6.0_45'
#File.join(node['java']['java_home'], 'jdk1.6.0_45')

execute "Setting JAVA_HOME environmental variable." do
  command 'echo JAVA_HOME="'+ jdk +'" >> /etc/environment; echo PATH=$PATH:'+ jdk +'/bin >> /etc/environment'
  user 'root'
end

link "/etc/alternatives/java" do
  to jdk + '/bin'
  user 'root'
end

bash "Source /etc/environment" do
  code "source /etc/environment"
end

