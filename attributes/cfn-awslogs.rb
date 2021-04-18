default['cfn']['awslogs'].tap do |config|
  config['user'] = 'root'
  config['group'] = 'root'
  config['path'] = '/var/awslogs'
  config['version'] = '1.4.5'
  config['region'] = nil
  config['streams'] = {}
  config['service'] = 'awslogs'
  config['service_actions'] = %w(enable)
end
