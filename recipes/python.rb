# Install common python dependencies
#
node.default['poise-python']['options']['get_pip_url'] = 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'
node.default['poise-python']['options']['pip_version'] = '18.0'
node.default['poise-python']['install_python2'] = true
node.default['poise-python']['install_python3'] = false
include_recipe 'poise-python'
