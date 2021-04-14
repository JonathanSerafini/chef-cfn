component = node['cfn']['recipes']

include_recipe 'chef_cfn::python'
include_recipe 'chef_cfn::ohai'       if component['ohai']
include_recipe 'chef_cfn::handler'    if component['handler']
include_recipe 'chef_cfn::cloudwatch' if component['cloudwatch']
include_recipe 'chef_cfn::cloudinit'  if component['cloudinit']
include_recipe 'chef_cfn::mounts'     if component['mounts']
include_recipe 'chef_cfn::tools'      if component['tools']
# include_recipe 'chef_cfn::awslogs'    if component['awslogs']
include_recipe 'chef_cfn::shutdown'   if component['shutdown']
