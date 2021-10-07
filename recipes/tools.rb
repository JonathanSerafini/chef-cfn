# Install aws-cfn-bootstrap which will provide
# - cfn-init    : cloudformation node init
# - cfn-hup     : cloudformation monitor and event trigger
# - cfn-signal  : cloudformation send signals for Policy
# - cfn-get-metadata
#
[
  'lockfile-0.12.2-py2.py3-none-any.whl',
  'pystache-0.5.4.tar.gz',
	'python-daemon-1.6.1.tar.gz'
].each do |name|
  cookbook_file "/tmp/#{name}" do
    source  name
    owner   'root'
    group   'root'
    mode    '0444'
    action  :create
  end

  python_execute "-m pip install /tmp/#{name}" do
      python '2'
  end
end

python_execute "-m pip install #{node['cfn']['tools']['url']}"

# Create cfn-hup configurations
#
directory '/etc/cfn/hooks.d' do
  recursive true
  mode '0700'
end

template '/etc/cfn/cfn-hup.conf' do
  variables lazy {
    {
      stack:    node['cfn']['stack']['stack_name'],
      region:   node['cfn']['vpc']['region_id'],
      interval: node['cfn']['tools']['cfn_hup']['interval'],
      verbose:  node['cfn']['tools']['cfn_hup']['verbose']
    }
  }
  only_if do
    node['cfn']['stack']['stack_name'] rescue false
  end
end

# Create hook to execute action on metadata change
#
template '/etc/cfn/hooks.d/cfn-auto-reloader.conf' do
  source 'hooks.d/cfn_auto_reloader.conf.erb'
  variables lazy {
    {
      stack:      node['cfn']['stack']['stack_name'],
      region:     node['cfn']['vpc']['region_id'],
      logical_id: node['cfn']['stack']['logical_id'],
      properties: node['cfn']['properties'],
      configsets: 'chef_exec'
    }
  }
  only_if do
    node['cfn']['stack']['stack_name'] rescue false
  end
end
