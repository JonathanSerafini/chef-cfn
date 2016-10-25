# Override the cloud-init configuration file with something more specific
# to the ec2 environment.
#
# The provided defaults are stripped down and work on the assumption that
# this is a node that has previously been generated with something like
# Packer.
#
template '/etc/cloud/cloud.cfg' do
  source 'cloudinit/cloud.cfg.erb'
  variables lazy { node['cfn']['cloudinit'] }
  only_if do
    ::File.directory?('/etc/cloud')
  end
end

Array(node['cfn']['cloudinit']['delete_cfgs']).each do |cfg|
  template ::File.join('/etc/cloud', cfg) do
    source 'cloudinit/empty.cfg.erb'
    action :delete
    only_if do
      ::File.directory?('/etc/cloud')
    end
  end
end
