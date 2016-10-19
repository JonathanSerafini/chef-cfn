# This code is taken from marpada/awslogs-cookbook and modified slightly
#

%w(bin etc lib local state).each do |f|
  directory "#{node['cfn']['awslogs']['path']}/#{f}" do
    owner node['cfn']['awslogs']['user']
    group node['cfn']['awslogs']['group']
    mode '0755'
    recursive true
  end
end

python_virtualenv node['cfn']['awslogs']['path'] do
  action :create
  owner node['cfn']['awslogs']['user']
  group node['cfn']['awslogs']['group']
end

python_pip 'awscli-cwlogs' do
  virtualenv node['cfn']['awslogs']['path']
  version node['cfn']['awslogs']['version']
end

template "#{node['cfn']['awslogs']['path']}/etc/aws.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'awslogs/aws.conf.erb'
  variables lazy {
    {
      region: node['cfn']['awslogs']['region'] ||
              node['cfn'].fetch('vpc', {}).fetch('region_id', 'us-east-1')
    }
  }
  notifies :restart, "service[#{node['cfn']['awslogs']['service']}]"
end

template "#{node['cfn']['awslogs']['path']}/etc/awslogs.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'awslogs/awslogs.conf.erb'
  variables lazy {
    {
      ohai_properties: node['cfn']['properties'],
      ohai_stack: node['cfn']['stack'],
      ohai_tags: node['cfn']['tags'],
      ohai_vpc: node['cfn']['vpc'],
      streams: node['cfn']['awslogs']['streams'],
      path: node['cfn']['awslogs']['path']
    }
  }
  notifies :restart, "service[#{node['cfn']['awslogs']['service']}]"
end

service node['cfn']['awslogs']['service'] do
  action node['cfn']['awslogs']['service_actions']
  only_if do
    node['ec2']
  end
end
