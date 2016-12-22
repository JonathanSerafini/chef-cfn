# Ensure deletes the node and client upon shutdown
#
template '/etc/init.d/chef_lifecycle' do
  source 'shutdown/chef_lifecycle.erb'
  mode '0750'
end

service 'chef_lifecycle' do
  action node['cfn']['shutdown']['service_actions']
end
