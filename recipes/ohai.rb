# Install dependencies
#
{
	'aws-eventstream' => '1.1.1',
	'jmespath' => '1.4.0',
	'aws-sigv4' => '1.2.4',
	'aws-sdk' => '2.11.632'
}.each do |name, vers|
chef_gem name do
  version vers
  compile_time true if respond_to?(:compile_time)
end
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
