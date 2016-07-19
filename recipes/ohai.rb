
#
# Install the Ohai cookbook
# - creates directories and installs ohai[cfn]
#
include_recipe 'ohai::default'

#
# Ensure AWS-SDK is installed
# - reload ohai[cfn] for first-boot scenarios
#

chef_gem 'aws-sdk' do
  compile_time true if respond_to?(:compile_time)
end

ohai 'cfn' do
  plugin 'cfn'
end.run_action(:reload)
