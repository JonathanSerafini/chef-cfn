default['cfn']['cloudinit'].tap do |config|
  config['delete_cfgs'] = %w(
    90_dpkg.cfg
  )

  config['cloud_params'].tap do |params|
    # Disable cloud-init behavior affecting root
    params['disable_root'] = false

    # Disable cloud-init behavior affecting etc/hosts
    params['manage_etc_hosts'] = false

    # Enable changing the hostname based on the Ec2 id
    params['preserve_hostname'] = false
  end

  # Modules that should run during early boot
  config['cloud_init_modules'] = %w(
    seed_random
    growpart
    resizefs
    set-hostname
    update-hostname
  )

  # Modules that should run after boot
  config['cloud_config_modules'] = %w(
    emit_upstart
    disk_setup
    mounts
    runcmd
  )

  # Modules that should run after config
  config['cloud_final_modules'] = %w(
    rightscale_userdata
    scripts-vendor
    scripts-per-once
    scripts-per-boot
    scripts-per-instance
    scripts-user
  )
end
