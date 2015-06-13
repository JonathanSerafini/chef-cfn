
#
# Provide minimal knife.rb based on chef-client.rb
#
cookbook_file "/etc/chef/knife.rb" do
  mode "0640"
end

