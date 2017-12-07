# Install dependencies
#
chef_gem 'aws-sdk' do
  version '~> 2'
  compile_time true if respond_to?(:compile_time)
end

# Reload the cfn plugin on notify
#
ohai 'cfn' do
  plugin 'cfn'
  action :nothing
end

# Install the custom ohai plugin
#
ohai_plugin 'cfn' do
  source_file 'ohai_plugins/cfn.rb'
  compile_time true
  notifies :reload, 'ohai[cfn]'
end
