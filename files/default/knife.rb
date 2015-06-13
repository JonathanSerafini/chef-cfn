
%w(node_name chef_server_url).each do |pattern|
  value = File.open('/etc/chef/client.rb','r').grep(/#{pattern}/).first
  value = value.split(' ').last.gsub('"','')
  send(pattern, value)
end

