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
  pip_version false
  setuptools_version true
  system_site_packages true
end

python_execute "-m pip install setuptools" do
  virtualenv node['cfn']['awslogs']['path']
end

[
  'urllib3-1.21.1-py2.py3-none-any.whl',
  'six-1.15.0-py2.py3-none-any.whl',
  'pyasn1-0.4.8-py2.py3-none-any.whl',
  'rsa-3.3-py2.py3-none-any.whl',
  'python_dateutil-2.8.2-py2.py3-none-any.whl',
  'colorama-0.3.3.tar.gz',
  'jmespath-0.10.0.tar.gz',
  'docutils-0.17.1-py2.py3-none-any.whl',
  'botocore-1.7.48-py2.py3-none-any.whl',
  'futures-3.3.0-py2-none-any.whl',
  's3transfer-0.1.13-py2.py3-none-any.whl',  
  'awscli-1.11.190.tar.gz',
  'certifi-2017.4.17-py2.py3-none-any.whl',
  'chardet-3.0.4-py2.py3-none-any.whl',
  'idna-2.5-py2.py3-none-any.whl',
  'requests-2.18.4-py2.py3-none-any.whl',
  'awscli-cwlogs-1.4.6.tar.gz',
].each do |name|
  cookbook_file "/tmp/#{name}" do
    source  name
    owner   'root'
    group   'root'
    mode    '0444'
    action  :create
  end

  python_execute "-m pip install /tmp/#{name}" do
    virtualenv node['cfn']['awslogs']['path']
  end
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
