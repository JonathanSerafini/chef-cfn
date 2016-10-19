# Ensure deletes the node and client upon shutdown
#
cookbook_file '/etc/init.d/chef_lifecycle' do
  mode '0750'
end

service 'chef_lifecycle' do
  action node['cfn']['shutdown']['service_actions']
end
