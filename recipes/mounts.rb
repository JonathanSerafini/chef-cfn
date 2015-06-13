
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

    if mount_point == "/mnt" and
       node[:filesystem][device] and
       node[:filesystem][device][:mount] != mount_point

      mount "/mnt" do
        mount_point "/mnt"
        device device
        action [:disable, :unmount]
      end
    end

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
      actions [:enable, :mount]
    end
  end
end

