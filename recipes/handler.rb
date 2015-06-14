
#
# Install Chef-Run handlers
# - with working ohai[cfn], this allows signaling cloudformation
#
include_recipe "chef_handler::default"

path = ::File.join(node[:chef_handler][:handler_path], "cfn_signal.rb")
cookbook_file path do
  source "chef_handlers/cfn_signal.rb"
  mode "0644"
end

chef_handler "cloudformation_signal_handler" do
  source path
  arguments lazy {
    {
      url: node[:cfn][:properties][:wait_handlers][:chef_run_finished],
      unique_id: node[:cfn][:ec2][:instance_id],
      data: "Chef run complete"
    }
  }
  only_if do
    node[:cfn][:properties][:wait_handlers][:chef_run_finished] rescue false
  end
end

