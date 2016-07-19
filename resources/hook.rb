
#
# cfn-hup hook resource
# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-hup.html
#

actions :create, :delete
default_action :create

# Command path to execute when the hook triggers
attribute :command,
  kind_of: [String, Array],
  required: true

# Path to the CloudFormation object to watch for changes
attribute :path,
  kind_of: String,
  required: true

# Command to runas
attribute :runas, 
  kind_of: String,
  default: 'root'

# Trigger hook on this CloudFormation metadata action
attribute :triggers,
  kind_of: [String, Array],
  equal_to: %w(post.add post.update posr.remove)

