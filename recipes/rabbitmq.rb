unless node.cleartext_passwords
  include_recipe 'chef-vault'
  rogue_rabbitmq_user = default['rabbitmq']['rogue_user']
  rabbitmq_vault = default['rabbitmq']['rogue_user'][:password]
  rogue_rabbitmq_user[:password] = chef_vault_item(rabbitmq_vault[:vault], rabbitmq_vault[:item])[rabbitmq_vault[:field]]
  node.normal.rabbitmq.enabled_users = [rogue_rabbitmq_user]
end

include_recipe 'rabbitmq'
include_recipe 'rabbitmq::user_management'
