default['cfn']['tools'].tap do |config|
  config['url'] = 'https://s3.amazonaws.com/cloudformation-examples' \
                  '/aws-cfn-bootstrap-latest.tar.gz'

  config['cfn_hup']['interval'] = 10
  config['cfn_hup']['verbose'] = 'no'

  config['signal_cloudformation'] = true
end
