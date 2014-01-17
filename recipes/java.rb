node.default['java']['oracle']['accept_oracle_download_terms'] = true
node.default['java']['install_flavor']= "oracle"
node.default['java']['jdk_version'] = '6'
node.default['java']['java_home']='/usr/lib/jvm/jdk1.6.0_45'

include_recipe "java::default"
include_recipe "java::oracle"

link "/usr/bin/java" do
  to node['java']['java_home'] + '/bin/java'
  user 'root'
end


