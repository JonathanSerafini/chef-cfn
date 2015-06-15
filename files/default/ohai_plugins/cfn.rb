
require 'chef/json_compat'

Ohai.plugin(:CFN) do
  provides "cfn/tags",
           "cfn/stack",
           "cfn/vpc",
           "cfn/properties"

  depends "ec2"

  collect_data do
    cfn Mash.new
    cfn[:vpc]   = Mash.new
    cfn[:tags]  = Mash.new
    cfn[:stack] = Mash.new
    cfn[:properties]  = Mash.new

    begin
      require 'aws-sdk-core'
    rescue LoadError => e
      Ohai::Log.error("cfn - cannot load gem: aws-sdk-core")
      raise
    end

    unless hint?("ec2")
      Ohai::Log.error("cfn - ec2 ohai module failed to load")
      raise ArgumentError, "ec2 ohai module failed to load"
    end

    region      = ec2[:placement_availability_zone][0...-1]
    instance_id = ec2[:instance_id]

    # 
    # Fetch a hash of instance data
    #
    begin
      client = Aws::EC2::Client.new(region: region)
      instance = client.
        describe_instances(instance_ids: [instance_id]).
        reservations.first.
        instances.first.to_h
    rescue Exception => e
      Ohai::Log.error("cfn: failed to fetch instance: #{e.message}")
      raise
    end
  
    # Store some vpc related attributes
    cfn[:vpc][:vpc_id] = instance[:vpc_id]
    cfn[:vpc][:subnet_id] = instance[:subnet_id]
    cfn[:vpc][:region_id]  = region

    # SnakeCase attribute keys
    tags = instance[:tags].map do |hash|
      hash_key = hash[:key].
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr('-', '_').
        gsub(/\s/, '_').
        gsub(/__+/, '_').
        downcase
      [hash_key, hash[:value]]
    end

    # Store instance tags
    cfn[:tags] = Hash[tags]

    # Store cloudformation stack related attributes
    cfn[:stack][:stack_id]   = cfn[:tags]["aws:cloudformation:stack_id"]
    cfn[:stack][:stack_name] = cfn[:tags]["aws:cloudformation:stack_name"]
    cfn[:stack][:logical_id] = cfn[:tags]["aws:cloudformation:logical_id"]
    cfn[:stack][:autocaling_name]= cfn[:tags]["aws:autoscaling:group_name"]

    #
    # Fetch a hash of stack resource metadata
    #
    if cfn[:stack][:stack_name]
      begin 
        client = Aws::CloudFormation::Client.new(region: region)
        resource = client.
          describe_stack_resource(stack_name: cfn[:stack][:stack_name],
                         logical_resource_id: cfn[:stack][:logical_id]).
          stack_resource_detail.to_h
      rescue Exception => e
        Ohai::Log.debug("cfn: failed to fetch stack: #{e.message}")
        resource = {}
      end

      unless resource.empty? or resource[:metadata].nil?
        begin
          # Fetch metadata if present
          metadata = Chef::JSONCompat.
                      from_json(resource[:metadata], symbolize_keys: true)
          metadata.each { |k,v| cfn[:properties][k] =v }
        rescue Exception => e
          Ohai::Log.debug("cfn: failed to parse metadata: #{e.message}")
        end
      else
        Ohai::Log.debug("cfn: no metadata found: #{cfn[:stack][:logical_id]}")
      end
    end

    # 
    # Add additional properties from hints file
    #
    cfn_properties_hints = hint?("cfn_properties") || {}
    cfn_properties_hints.each { |k,v| cfn[:properties][k] = v }
  end
end

