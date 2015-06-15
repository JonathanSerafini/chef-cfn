
require 'chef/handler'

module CFN
  class CloudFormationSignalHandler < ::Chef::Handler
    attr_reader :region
    attr_reader :stack_name
    attr_reader :logical_id
    attr_reader :unique_id

    def initialize(config={})
      @config = config

      %w(region unique_id logical_id stack_name).each do |key|
        next if config.key?(key.to_sym)
        raise ArgumentError, "Handler requires a value for: :#{key}"
      end

      @region     = config[:region]
      @stack_name = config[:stack_name]
      @logical_id = config[:logical_id]
      @unique_id  = config[:unique_id]
    end

    def report
      status = run_status.success? ? "SUCCESS" : "FAILURE"

      begin
        require 'aws-sdk-core'
        client = Aws::CloudFormation::Client.new(region: region)
        client.signal_resource(
          stack_name: stack_name,
          logical_resource_id: logical_id,
          unique_id: unique_id,
          status: status
        )
      rescue Exception => e
        Chef::Log.warn "Failed to signal CloudFormation, reason: #{e.inspect}"
      end
    end
  end
end

