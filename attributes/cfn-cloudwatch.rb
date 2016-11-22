node['cfn']['cloudwatch'].tap do |config|
  config['report_failure'] = true
  config['report_success'] = false
  config['report_cookbooks'] = true
end
