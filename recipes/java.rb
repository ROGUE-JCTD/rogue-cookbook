node.set['java']['oracle']['accept_oracle_download_terms'] = true
node.set['java']['install_flavor']= "oracle"
node.set['java']['jdk_version'] = '6'
node.set['java']['java_home']='/usr/lib/jvm/jdk1.6.0_45'

include_recipe "java::default"
include_recipe "java::oracle"

link "/usr/bin/java" do
  to node['java']['java_home'] + '/bin/java'
  user 'root'
end


