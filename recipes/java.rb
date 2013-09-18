node.set['java']['oracle']['accept_oracle_download_terms'] = true
node.set['java']['install_flavor']= "oracle"

include_recipe "java::default"
include_recipe "java::oracle"

jdk = File.join(node['java']['java_home'], 'jdk1.6.0_45')

execute "Setting JAVA_HOME environmental variable." do
  command 'echo JAVA_HOME="'+ jdk +'" >> /etc/profile && echo "PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile'
end