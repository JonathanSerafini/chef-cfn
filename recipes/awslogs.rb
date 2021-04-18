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
  user node['cfn']['awslogs']['user']
  group node['cfn']['awslogs']['group']
  get_pip_url 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'  
  pip_version true
  setuptools_version true
end

python_execute "-m pip install setuptools" do
  virtualenv node['cfn']['awslogs']['path']
end

python_execute "-m pip install awscli-cwlogs" do
  virtualenv node['cfn']['awslogs']['path']
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

template 'awslogs-service-template' do
  path '/etc/init/awslogs.conf'
  source 'awslogs/upstart.conf.erb'
  variables lazy {
    {
      path: node['cfn']['awslogs']['path'],
      user: node['cfn']['awslogs']['user'],
      group: node['cfn']['awslogs']['group']
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
