# Actions to pass to the cloudformation de-registration service
# @since 0.1.0
default['cfn']['shutdown']['service_actions'] = %w(enable)

# Name of the node which should be deleted when the service executes
#
# This option supports the following values:
# - DETECT_CLIENTNAME: grep the node_name from /etc/chef/client.rb
# - DETECT_NODENAME: node.name
# - DETECT_HOSTNAME: hostname --fqdn
# - *: Any other value is considered as the node_name you wish to delete
#
# @since 2.2.0
default['cfn']['shutdown']['node_name'] = 'DETECT_CLIENTNAME'
