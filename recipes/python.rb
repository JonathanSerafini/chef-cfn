# Install common python dependencies
#
include_recipe 'python'

python_pip 'pip' do
  version '1.5.4'
end
