
Ohai.plugin(:CFN) do
  provides "cfn/tags",
           "cfn/stack",
           "cfn/vpc",
           "cfn/properties"

  depends "ec2"

  collect_data do
    cfn[:vpc]   = Mash.new
    cfn[:tags]  = Mash.new
    cfn[:stack] = Mash.new
    cfn[:properties]  = Mash.new
      
    begin
      require 'aws-sdk-core'
      have_gem = true
    rescue LoadError => e
      Ohai::Log.debug("Cannot load gem: aws-sdk-core")
    end

    if have_gem and ec2 = hint?("ec2")
      region      = ec2[:placement_availability_zone][0...-1]
      instance_id = ec2[:instance_id]

      cfn[:stack][:region_id]  = region

      # 
      # Fetch a hash of instance data
      #
      begin
        client = Aws::EC2::Client.new(region: region)
        instance = client.
          describe_instances(instance_ids: [aws_instance_id]).
          reservations.first.
          instances.first.to_h rescue {}
      rescue Exception => e
        Ohai::Log.debug("Failed to fetch instance: #{e.message}")
        instance = {}
      end

      unless instance.empty?
        # Store some vpc related attributes
        cfn[:vpc][:vpc_id] = instance[:vpc_id]
        cfn[:vpc][:subnet_id] = instance[:subnet_id]

        # Store instance tags
        cfn[:tags] = Hash[instance[:tags].each do |hash|
          [hash[:key].downcase, hash[:value]]
        end]

        # Store cloudformation stack related attributes
        cfn[:stack][:stack_id]   = cfn[:tags]["aws:cloudformation:stack-id"]
        cfn[:stack][:stack_name] = cfn[:tags]["aws:cloudformation:stack-name"]
        cfn[:stack][:logical_id] = cfn[:tags]["aws:cloudformation:logical-id"]
        cfn[:stack][:autocaling_name]= cfn[:tags]["aws:autoscaling:groupName"]
      end

      #
      # Fetch a hash of stack resource metadata
      #
      if cfn[:stack][:stack_name]
        begin 
          client = Aws::CloudFormation::Client.new(region: region)
          resource = client.
            describe_stack_resource(stack_name: cfn[:stack][:stack_name],
                           logical_resource_id: cfn[:stack][:logical_id]).
            stack_resource_detail.to_h rescue {}
        rescue Exception => e
          Ohai::Log.debug("Failed to fetch stack: #{e.message}")
          resource = {}
        end

        unless resource.empty? or resource.metadata.nil?
          begin
            # Fetch metadata if present
            metadata = JSONCompat.
              from_json(resource.metadata, symbolize_keys: true)
            metadata.each { |k,v| cfn[:properties][k] =v }
          rescue Exception => e
            Ohai::Log.debug("Failed to parse metadata: #{e.message}")
          end
        else
          Ohai::Log.debug("No metadata found: #{cfn[:stack][:logical_id]}")
        end
      end

      # 
      # Add additional properties from hints file
      #
      cfn_properties_hints = hint?("cfn_properties") || {}
      cfn_properties_hints.each { |k,v| cfn[:properties][k] = v }
    else
      Ohai::Log.debug("Could not fetch instance details")
    end
  end
end

