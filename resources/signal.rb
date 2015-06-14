
#
# cfn-signal resource
# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-signal.html
#

actions :signal
default_action :signal

# AWS::CloudFormation::WaitConditionHandle URL
attribute :url,
  kind_of: String,
  required: true

# Unique ID to send
attribute :unique_id,
  kind_of: String,
  required: true

# Data to send back to the waitConditionHandle
attribute :data,
  kind_of: String,
  default: ""

# Trigger a Success or Failure event
attribute :success,
  kind_of: [FalseClass, TrueClass],
  default: true

# Status reason for the resource (failure) event
attribute :reason,
  kind_of: String,
  default: "Chef triggered signal from resource"

# Ensure signal is only sent once
attribute :once,
  kind_of: [TrueClass, FalseClass],
  default: true

# Message body sent as as part of the signal
def message
  status = new_resource.success ? "SUCCESS" : "FAILURE"
  {
    Status: status,
    UniqueId: unique_id,
    Data: data,
    Reason: reason
  }
end

#
# Overload constructor
#
def initialize(*args)
  # Ensure the signal_sent state is present
  node.run_state[:signals_sent] ||= []

  # Provide a default unique_id
  @unique_id = node[:hostname] + "-" + Random.rand(10**5).to_s

  super

  # Ensure that this only runs on EC2 instances
  only_if do
    node.attribute?(:ec2)
  end

  # Ensure that this only runs once if requested
  not_if do
    once and node.run_state[:signals_sent].includes?(url)
  end
end

