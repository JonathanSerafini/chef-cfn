# Install common python dependencies
#
# include_recipe 'poise-python'
python_runtime '2' do
    options get_pip_url: 'https://bootstrap.pypa.io/pip/2.7/get-pip.py',
            pip_version: false,
            setuptools_version: false,
            wheel_version: false,
            virtualenv_version: false
    get_pip_url 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'
    pip_version false
    setuptools_version false
    wheel_version false
    virtualenv_version false
end

remote_file '/tmp/get-pip.py' do
  source 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'
  action :create
end

python_execute '/tmp/get-pip.py --trusted-host=files.pythonhosted.org --trusted-host=pypi.org' do
    python '2'
end
