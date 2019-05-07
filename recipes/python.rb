# Install common python dependencies
#
node.default['poise-python']['options']['pip_version'] = '18.0'
node.default['poise-python']['install_python2'] = false
node.default['poise-python']['install_python3'] = true
include_recipe 'poise-python'
