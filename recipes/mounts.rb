
#
# Manage cloudformation defined mounts
# device => {
#   mount_point: /target/directory,
#   mount_options: "mount arguments",
#   filesystem: "ext4" || "snap-342643"
# }
#
if node[:cfn][:properties] and node[:cfn][:properties][:mounts]
  node[:cfn][:properties][:mounts].each do |device_id, mount_opts|
    device  = "/dev/#{device_id}"

    mount_point   = mount_opts[:mount_point]
    mount_options = mount_opts[:options] || "noatime,nodiratime,nobootwait"
    filesystem    = mount_opts[:filesystem] || "ext4"

    unless ::File.blockdev?(device)
      raise ArgumentError, "Device not found: #{device_id}"
    end

    # EC2 instances are spun up with a ephemeral drive on /mnt. 
    # - unmount it if it conflicts
    if mount_point == "/mnt" and
       node[:filesystem][device] and
       node[:filesystem][device][:mount] != mount_point

      mount "/mnt" do
        mount_point "/mnt"
        device device
        action [:disable, :unmount]
      end
    end

    # In order to support early mounting, create any missing directories
    # if they do not exist
    unless ::File.exists?(mount_point)
      directory mount_point do
        recursive true
      end
    end

    # Create the filesystem if non exists and if this wasn't declared as
    # being a snapshot source
    execute "mkfs #{device_id}" do
      command "mkfs -t #{filesystem} #{device}"
      not_if do
        node[:filesystem][device] and node[:filesystem][device][:mount]
      end
      not_if do
        filesystem =~ /^snap-/
      end
    end

    mount device do
      mount_point mount_point
      device device
      options mount_options
      action [:enable, :mount]
    end
  end
end

