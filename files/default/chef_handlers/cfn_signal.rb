
#
# https://github.com/fewbytes-cookbooks/cloudformation
#

require 'chef/handler'

require 'net/http'
require 'uri'

class Chef
  class Handler
    class CloudFormationSignalHandler < ::Chef::Handler
      attr_reader :unique_id
      attr_reader :signal_url
      attr_reader :signal_once
      attr_reader :report_data

      def initialize(config={})
        @config = config

        %w(url data unique_id).each do |key|
          next if config.key?(key.to_sym)
          raise ArgumentError, "Handler requires a value for: :#{key}"
        end

        @report_data    = config[:data]
        @unique_id      = config[:unique_id]
        @signal_url     = config[:url]
        @signal_once    = config[:once] || false
      end

      def report_data
        if report_data.is_a?(Proc)
          return report_data.call
        else
          return report_data.to_s
        end
      end

      def report
        url = URI.parse(signal_url)
        if run_status.success? 
          status = "SUCCESS"
          data = report_data
          reason = "Chef run has completed successfully"
        else
          status = "FAILURE"
          data = run_status.formatted_exception
          reason = "Chef run has failed"
        end
        signal(url, status, reason, data)
      end

      def signal(url, status, reason, data)
        req = ::Net::HTTP::Put.new(url.request_uri)
        req.content_type = ""

        req.body = {
          Status:   status,
          UniqueId: unique_id.to_s,
          Reason:   reason,
          Data:     data
        }.to_json

        if signal_once
        and run_status.node.run_state[:signals_sent].include?(url.to_s)
          Chef::Log.info "Not signaling because CloudFormation signal #{new_resource.name} has alredy been sent and `once` is true"
          return
        end

        begin
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true if url.scheme = "https"
          resp = http.start do |http|
            http.request(req)
          end
          unless resp.code_type == Net::HTTPOK
            Chef::Log.warn "CloudFormation API returned #{resp.code}, reason #{resp.body}"
          end
        rescue Exception => e
          Chef::Log.warn "Failed to signal CloudFormation, reason: #{e.inspect}"
        end

        if signal_once
          run_status.node.set[:cfn][:signals_sent] << url.to_s
        end
      end
    end
  end
end

