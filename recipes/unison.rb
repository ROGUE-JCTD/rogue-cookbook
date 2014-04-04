unison_packages = ['unison', 'acl', 'keychain', 'augeas-tools']

unison_packages.each do |pkg|
  package pkg do
    action :install
  end
end

execute "update_fstab" do
  command <<-EOF
    echo 'ins opt after /files/etc/fstab/*[file="/"]/opt[last()]
    set /files/etc/fstab/*[file="/"]/opt[last()] acl
    save' | augtool
    mount -o remount /
  EOF
  not_if "grep acl /etc/fstab" # TODO: Switch to something similar to this, augtool match '/files/etc/fstab/*[file=\"/\" and count(opt[.=\"acl\"])=0]'
end

execute "generate_ssh_key" do
  command "ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P \"\" "
  user 'root'
  action :run
  not_if 'ls ~/.ssh/id_rsa'
end

#directory ".ssh" do
#  path '/root/.ssh'
#  owner "root"
#  group "root"
#  mode 600
#  action :create
#end

#file "create_rogue_private_key" do
#  path node['rogue']['ssh']['private_key_remote_file']
#  owner "root"
#  group "root"
#  mode 00700
#  action :create
#end

#file "create_rogue_public_key" do
#  path node['rogue']['ssh']['public_key_remote_file']
#  owner "root"
#  group "root"
#  mode 00600
#  action :create
#end

execute "copy_private_key" do
  command <<-EOH
  cat <<EOF>> #{node['rogue']['ssh']['private_key_remote_file']}
  #{node['rogue']['ssh']['private_key']}
  EOH
  not_if do File.exists? node['rogue']['ssh']['private_key_remote_file'] end
  only_if do node['rogue']['ssh']['private_key'] end
end

execute "copy_public_key" do
  command <<-EOH
  cat <<EOF>> #{node['rogue']['ssh']['public_key_remote_file']}
  #{node['rogue']['ssh']['public_key']}
  EOH
  not_if do File.exists? node['rogue']['ssh']['public_key_remote_file'] end
  only_if do node['rogue']['ssh']['private_key'] end
end

execute "add_ssh_to_profile" do
  command <<-EOH
    cat <<EOF>> /root/.profile
### START-Keychain ###
# Let  re-use ssh-agent and/or gpg-agent between logins
/usr/bin/keychain --clear $HOME/.ssh/id_rsa
source $HOME/.keychain/$HOSTNAME-sh
### End-Keychain ###
  EOH
  user 'root'
  action :nothing
  not_if "grep 'START-Keychain' /root/.profile"
  only_if do File.exists? '/root/.ssh/id_rsa' end
end
