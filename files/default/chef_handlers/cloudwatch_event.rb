require 'aws-sdk-core'
require 'chef/handler'

module CFN
  class CloudWatchEventHandler < Chef::Handler
    def initialize(region: nil, config: {})
      @region = region

      @event_source = config.fetch(:event_source, 'chef')
      @event_type = config.fetch(:event_type, 'chef.report')
      @event_data = config.fetch(:event_data, {})

      @report_failure = config.fetch(:report_failure, true)
      @report_success = config.fetch(:report_success, false)
      @report_cookbooks = config.fetch(:report_cookbooks, false)

      config
    end

    def cookbook_versions
      cookbooks = run_status
                  .run_context
                  .cookbook_collection
                  .map do |_, cookbook|
                    [cookbook.name.to_s, cookbook.version]
                  end
      cookbooks.sort_by! { |name, _| name }
      Hash[cookbooks]
    end

    def stack_name
      node_cfn.fetch('stack', {}).fetch('stack_name', nil)
    end

    def instance_id
      node_ec2['instance_id']
    end

    def node_cfn
      node['cfn'] || {}
    end

    def node_ec2
      node['ec2'] || {}
    end

    def report
      return false if run_status.success? && !@report_success
      return false if !run_status.success? && !@report_failure

      event = {
        time: ::Time.now,
        source: @event_source,
        detail_type: @event_type,
        detail: nil
      }

      detail = event[:detail] = {
        'EC2InstanceId' => instance_id,
        'AutoScalingGroupName' => stack_name,
        'chef' => {
          'name' => node.name,
          'run' => {
            'backtrace' => run_status.backtrace,
            'exception' => run_status.exception,
            'elapsed' => run_status.elapsed_time,
            'result' => run_status.success? ? 'SUCCESS' : 'FAILURE',
            'run_list' => node.run_list
          }
        }
      }

      detail['chef']['cookbooks'] = cookbook_versions if @report_cookbooks
      detail.merge!(@event_data)

      event[:detail] = Chef::JSONCompat.to_json_pretty(event[:detail])

      begin
        client = Aws::CloudWatchEvents::Client.new(region: @region)

        response = client.put_events(
          entries: [event]
        )

        if response.failed_entry_count > 0
          response.entries.each do |entry|
            Chef::Log.warn 'Failed to emit event, ' \
                           "reason: #{entry.error_message}"
          end
        end
      rescue StandardError => e
        Chef::Log.warn 'Failed to emit event, ' \
                        "reason: #{e.inspect}"
      end
    end
  end
end
