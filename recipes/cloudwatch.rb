# Install Chef-Run handlers
#
include_recipe 'chef_handler::default'

path = ::File.join(node['chef_handler']['handler_path'], 'cloudwatch_event.rb')
cookbook_file path do
  source 'chef_handlers/cloudwatch_event.rb'
  mode '0644'
end

chef_handler 'CFN::CloudWatchEventHandler' do
  source path
  arguments lazy {
    {
      region:     node['cfn']['vpc']['region_id'],
      config: {
        report_failure: true,
        report_success: true,
        report_cookbooks: true
      }
    }
  }
end
