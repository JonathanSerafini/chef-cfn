
#
# Install the Ohai cookbook
# - creates directories and installs ohai[cfn]
#
include_recipe "ohai::default"

#
# Ensure AWS-SDK is installed
# - reload ohai[cfn] for first-boot scenarios
#
chef_gem "aws-sdk" do
  notifies :reload, "ohai[cfn]", :immediately
end

ohai "cfn" do
  plugin "cfn"
  action :nothing
end

