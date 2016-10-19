# Feature flags which trigger which recipes the default recipe includes
#
default['cfn']['recipes'].tap do |config|
  config['awslogs']   = false
  config['cloudinit'] = false
  config['handler']   = true
  config['mounts']    = true
  config['shutdown']  = true
  config['tools']     = true
end
